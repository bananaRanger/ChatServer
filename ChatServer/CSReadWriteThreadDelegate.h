//
//  CSReadWriteThreadDelegate.h
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSReadWriteThreadDelegate <NSObject>

- (void) read : (BOOL) flag dataErrorWithErrorInfo : (int) error;
- (void) socketConnectionIsBroken;

@end
