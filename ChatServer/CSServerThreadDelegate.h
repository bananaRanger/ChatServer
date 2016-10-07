//
//  CSServerThreadDelegate.h
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSServerThreadDelegate <NSObject>

- (void) bindErrorWithErrorInfo : (int) error;
- (void) startListeningErrorWithErrorInfo : (int) error;
- (void) acceptErrorWithErrorInfo : (int) error;
- (void) readDataErrorWithErrorInfo : (int) error;
- (void) writeDataErrorWithErrorInfo : (int) error;
- (void) socketConnectionIsBroken;
- (void) connectingFromAddress : (NSString *) address;

@end
