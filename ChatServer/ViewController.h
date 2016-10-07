//
//  ViewController.h
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSServerThread.h"

@interface ViewController : NSViewController <CSServerThreadDelegate>
{
    IBOutlet NSLayoutConstraint *stateToTop;
    IBOutlet NSTextField *stateField;
    IBOutlet NSTextField *descriptionField;
    IBOutlet NSButton *startStopButton;
    IBOutlet NSTextView *textView;
    
    CSServerThread *serverThread;
    NSThread *thread;
}

- (IBAction) buttonIsClicked : (id) sender;

@end

