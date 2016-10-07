//
//  CSReadWriteThread.h
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "CSReadWriteThreadDelegate.h"
#import "CSDataProtocol.h"

static const int amount = 2048 * 8;

@interface CSReadWriteThread : NSObject
{
    int descriptor;
    __weak id<CSReadWriteThreadDelegate> delegate;
    CSDataProtocol *dataProtocol;
    NSObject *objectForSynchronizing;
}

@property (nonatomic, weak) id<CSReadWriteThreadDelegate> delegate;

- (instancetype) initWithDescriptor : (int) newDescriptor andSynchronizeObject : (NSObject *) object;
- (void) runReadWrite : (NSObject *) object;

@end
