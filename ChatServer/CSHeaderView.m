//
//  CSHeaderView.m
//  ChatServer
//
//  Created by Anthony on 14.08.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "CSHeaderView.h"

@implementation CSHeaderView

- (void)drawRect:(NSRect)dirtyRect {
    
    [[NSColor labelColor] setFill];
    NSRectFill(dirtyRect);
    [super drawRect:dirtyRect];
}

@end
