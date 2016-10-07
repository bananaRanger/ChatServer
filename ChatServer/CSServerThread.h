//
//  CSServerThread.h
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import "CSReadWriteThread.h"
#import "CSServerThreadDelegate.h"

@interface CSServerThread : NSObject <CSReadWriteThreadDelegate>
{
    NSInteger port;
    int socketDescriptor;
    __weak id<CSServerThreadDelegate> delegate;
}

@property NSInteger port;
@property (nonatomic, weak) id<CSServerThreadDelegate> delegate;

- (instancetype) initWithPort : (NSInteger) newPort;
- (void) runServer : (NSObject *) object;
- (void) closeServer;

@end
