//
//  CSServerThread.m
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "CSServerThread.h"

@implementation CSServerThread

@synthesize port;
@synthesize delegate;

- (instancetype) initWithPort : (NSInteger) newPort {
    self = [super init];
    if (self != nil) {
        self->port = newPort;
        self->socketDescriptor = 0;
    }
    return self;
}

- (void) runServer : (NSObject *) object {
    @autoreleasepool {
        
        self->socketDescriptor = socket(PF_INET, SOCK_STREAM, IPPROTO_TCP);
        struct sockaddr_in sin;
        memset(&sin, 0, sizeof(sin));
        sin.sin_len = sizeof(sin);
        sin.sin_family = AF_INET;           // Or AF_INET6 (address family)
        sin.sin_port = htons(self->port);
        sin.sin_addr.s_addr = INADDR_ANY;
        
        if (bind(self->socketDescriptor, (struct sockaddr *)&sin, sizeof(sin)) < 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->delegate bindErrorWithErrorInfo:errno];
            });
            return;
        }
        
        if (listen(self->socketDescriptor, 5) != 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->delegate bindErrorWithErrorInfo:errno];
            });
            return;
        }
        
        NSThread *currentThread = [NSThread currentThread];
        
        while (currentThread.isCancelled == false) {
            
            struct sockaddr_in pAddr;
            socklen_t          pAddrSize = sizeof(struct sockaddr_in);
            
            int clientDescriptor = accept(self->socketDescriptor, (struct sockaddr *) &pAddr, &pAddrSize);
                        
            if (clientDescriptor == -1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self->delegate acceptErrorWithErrorInfo:errno];
                });
                break;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self->delegate connectingFromAddress:[self ipToString:pAddr.sin_addr.s_addr]];
            });
            
            NSObject *object = [[NSObject alloc] init];
            
            CSReadWriteThread *readWriteThread = [[CSReadWriteThread alloc] initWithDescriptor:clientDescriptor andSynchronizeObject:object];
            readWriteThread.delegate = self;
            NSThread *thread = [[NSThread alloc] initWithTarget:readWriteThread selector:@selector(runReadWrite:) object:nil];
            [thread start];
        }
    }
}

- (void) closeServer {
    close(self->socketDescriptor); // Закрытие серверного сокета
}

- (NSString *) ipToString : (unsigned int) address {
    
    unsigned int b1 = (address & 0xFF000000) >> 24;
    unsigned int b2 = (address & 0x00FF0000) >> 16;
    unsigned int b3 = (address & 0x0000FF00) >> 8;
    unsigned int b4 = (address & 0x000000FF);
    
    NSString *string = [NSString stringWithFormat:@"%u.%u.%u.%u", b4, b3, b2, b1];
    
    return string;
}

- (void) read : (BOOL) flag dataErrorWithErrorInfo : (int) error {
    
    if (flag == true) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->delegate readDataErrorWithErrorInfo:error];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->delegate writeDataErrorWithErrorInfo:error];
        });
    }
}

- (void) socketConnectionIsBroken {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->delegate socketConnectionIsBroken];
    });
}

@end
