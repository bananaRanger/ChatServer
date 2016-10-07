//
//  ViewController.m
//  ChatServer
//
//  Created by Anthony on 23.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self->textView setEditable:false];
}

- (IBAction) buttonIsClicked : (id) sender {
    
    if (self->serverThread == nil) {
        [[self.view.window standardWindowButton:NSWindowCloseButton] setEnabled:false];
        self->stateField.stringValue = @"Сервер включен";
        self->stateToTop.animator.constant += 8;
        self->descriptionField.stringValue = @"";
        self->serverThread = [[CSServerThread alloc] initWithPort:4000];
        self->serverThread.delegate = self;
        self->thread = [[NSThread alloc] initWithTarget:self->serverThread selector:@selector(runServer:) object:nil];
        [self->thread start];
        [self setLogMessage:@"Server is started"];
    } else {
        [[self.view.window standardWindowButton:NSWindowCloseButton] setEnabled:true];
        self->stateField.stringValue = @"Сервер выключен";
        self->stateToTop.animator.constant -= 8;
        self->descriptionField.stringValue = @"Нажмите кнопку, чтобы включить сервер";
        [self->thread cancel];
        [self->serverThread closeServer];
        self->serverThread = nil;
        [self setLogMessage:@"Server is stoped"];
    }
}

#pragma mark - CSServerThreadDelegate -

- (void) bindErrorWithErrorInfo : (int) error {
    [self setLogMessage:[NSString stringWithFormat:@"Binding error #%i", error]];
    NSLog(@"bind : %i", error);
}

- (void) startListeningErrorWithErrorInfo : (int) error {
    [self setLogMessage:[NSString stringWithFormat:@"Start listeting error #%i", error]];
    NSLog(@"startListening : %i", error);
}

- (void) acceptErrorWithErrorInfo : (int) error {
    [self setLogMessage:[NSString stringWithFormat:@"Accept error #%i", error]];
    NSLog(@"accept : %i", error);
}

- (void) readDataErrorWithErrorInfo : (int) error {
    [self setLogMessage:[NSString stringWithFormat:@"Read data error #%i", error]];
    NSLog(@"readDataErrorWithErrorInfo : %i", error);
}

- (void) writeDataErrorWithErrorInfo : (int) error {
    [self setLogMessage:[NSString stringWithFormat:@"Write data error #%i", error]];
    NSLog(@"writeDataErrorWithErrorInfo : %i", error);
}

- (void) socketConnectionIsBroken {
    [self setLogMessage:@"Socket connection is broken"];
    NSLog(@"socketConnectionIsBroken");
}

- (void) connectingFromAddress:(NSString *)address {
    if (address != nil) {
        [self setLogMessage:[NSString stringWithFormat:@"Connecting from address: %@", address]];
        NSLog(@"connect : %@", address);
    }
}

- (void) setLogMessage : (NSString *) message {
    NSString *value = self->textView.string;
    self->textView.string = [NSString stringWithFormat:@"%@\n - %@", value, message];
}

@end
