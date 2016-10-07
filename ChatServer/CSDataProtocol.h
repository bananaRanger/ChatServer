//
//  CSDataProtocol.h
//  ChatServer
//
//  Created by Anthony on 24.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDataProtocol : NSObject
{
    NSMutableDictionary *users;
    NSInteger messageID;
    NSMutableDictionary *messages;
}

+ (instancetype) sharedInstance;
- (NSString *) request : (char *) reqString descriptor: (int) descriptor;
- (void) deleteUser : (int) descriptor;

@end
