//
//  CSReadWriteThread.m
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "CSReadWriteThread.h"

@implementation CSReadWriteThread

@synthesize delegate;

- (instancetype) initWithDescriptor : (int) newDescriptor andSynchronizeObject : (NSObject *) object {
    self = [super init];
    if (self != nil) {
        self->descriptor = newDescriptor;
        self->dataProtocol = [CSDataProtocol sharedInstance];
        self->objectForSynchronizing = object;
    }
    return self;
}

- (void) runReadWrite : (NSObject *) object {
    @autoreleasepool {
        
        char buffer[amount];
        
        while (true) {
            
            long int count = read(self->descriptor, buffer, sizeof(buffer));
            if ([self isRead:true successfulOperationByResult:count] == false) { break; }
            
            buffer[count] = 0;
            
            NSString *answer = [self->dataProtocol request:buffer descriptor:self->descriptor];
            
            const char *buffer = [answer cStringUsingEncoding:NSUTF8StringEncoding];
                        
            count = write(self->descriptor, buffer, [answer lengthOfBytesUsingEncoding:NSUTF8StringEncoding]);
            if ([self isRead:false successfulOperationByResult:count] == false) {  break; }
        }
        
        @synchronized (self->objectForSynchronizing) {
            [self->dataProtocol deleteUser:self->descriptor];
            close(self->descriptor);
        }
    }
}

- (BOOL) isRead : (BOOL) readWriteFlag successfulOperationByResult : (long) count {
    
    if (count == -1) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->delegate read:readWriteFlag dataErrorWithErrorInfo:errno];
        });
    }
    if (count == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->delegate socketConnectionIsBroken];
        });
        return false;
    }
    return true;
}

@end
