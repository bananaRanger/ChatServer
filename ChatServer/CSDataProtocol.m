//
//  CSDataProtocol.m
//  ChatServer
//
//  Created by Anthony on 24.07.16.
//  Copyright © 2016 Anthony. All rights reserved.
//

#import "CSDataProtocol.h"

@implementation CSDataProtocol

+ (instancetype) sharedInstance {
    
    static CSDataProtocol *dataProtocol = nil;
    @synchronized (self) {
        if (dataProtocol == nil) {
            dataProtocol = [[self alloc] init];
        }
    }
    return dataProtocol;
}

- (instancetype) init {
    self = [super init];
    if (self != nil) {
        self->users = [NSMutableDictionary dictionary];
        self->messageID = 0;
        self->messages = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *) request : (char *) reqString descriptor: (int) descriptor {
    
    NSString *request = [NSString stringWithCString:reqString encoding:NSUTF8StringEncoding];
    NSRange range = [request rangeOfString:@"|"];
    
    if (range.location == NSNotFound) {
        return [self errorWithMessage:@"Некорректная комманда"];
    }
    
    NSString *command = [request substringToIndex:range.location];
    NSString *data    = [request substringFromIndex:range.location + 1];
    
    if ([command isEqualToString:@"LOGIN"]) {
        
        NSArray *array = [data componentsSeparatedByString:@"^"];
        
        if (array.count != 2) {
            return [self errorWithMessage:@"Ошибка при авторизации"];
        }
        
        NSString *name = [array objectAtIndex:0];
        NSString *image = [array objectAtIndex:1];
        
        if (name.length == 0) {
            return [self errorWithMessage:@"Введите ваше имя в чате"];
        }
        
        if ([self login:name] == true) {
            @synchronized (self) {
                [self->users setObject: [NSArray arrayWithObjects:name, image, nil] forKey:[NSNumber numberWithInt: descriptor]];
            }
            
            return [self messageAboutSuccess:@"LOGINOK"];
            
        } else {
            
            return [self errorWithMessage:@"Такой пользователь уже есть в чате"];
        }
       
    } else if ([command isEqualToString:@"USERLIST"]) {
        
        return [self userList];
        
    } else if ([command isEqualToString:@"MSGLIST"]) {
        
        NSInteger ID = [data integerValue]; 
        return [self messagesListFromID : ID];
        
    } else if ([command isEqualToString:@"NEWMS"]) {
        
        if (data.length > 150) {
            return [self errorWithMessage:@"Сообщение превышает 150 символов"];
        }
        if ([self obsceneExpression:data] == true) {
            return [self errorWithMessage:@"Сообщение содержит недопустимое выражение"];
        }
        
        @synchronized (self) {
            [self->messages setObject:[self makeMessageListFormat:descriptor messageText:data] forKey:[NSNumber numberWithInteger: self->messageID]];
        }
        self->messageID += 1;
        
        return [self messageAboutSuccess:@"NEWMSOK"];
        
    } else {
        return [self errorWithMessage:@"NONAME"];
    }
    
    return request;
}
- (NSDictionary *) makeMessageListFormat : (int) descriptor messageText: (NSString *) message {
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yy HH:mm"];
    NSString *time = [dateFormatter stringFromDate:[NSDate date]];
    
    NSNumber *number = [NSNumber numberWithInt:descriptor];
    for (NSNumber *key in self->users) {
        if ([key isEqualTo:number]) {
            
            NSArray *array = nil;
            
            @synchronized (self) {
                array = [self->users objectForKey:key];
            }
            
            NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:self->messageID], @"ID",
                                  [array objectAtIndex:0], @"name",
                                  [array objectAtIndex:1], @"img",
                                  message, @"text",
                                  time, @"time",
                                  nil];
            return info;
        }
    }
    return nil;
}
- (NSString *) errorWithMessage : (NSString *) message {
    
    NSMutableDictionary *error = [NSMutableDictionary dictionaryWithObject:message forKey:@"ERROR"];
    NSDictionary *results = [NSDictionary dictionaryWithObject:error forKey:@"error"];
    
    return [self stringFromDictionary:results];
}

- (NSString *) messageAboutSuccess : (NSString *) command {
    
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObject:command forKey:@"command"];
    NSDictionary *results = [NSDictionary dictionaryWithObject:dictionary forKey:@"results"];
    
    return [self stringFromDictionary:results];
}

- (NSString *) stringFromDictionary : (NSDictionary *) dictionary {
    
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    char *bytes = (char *)[jsondata bytes];
    bytes[[jsondata length]] = 0;
    NSString *returnString = [NSString stringWithCString:bytes encoding:NSUTF8StringEncoding];
    
    return returnString;
}

- (BOOL) login : (NSString *) userName {
    
    for (NSArray *array in self->users.allValues) {
        if ([[array objectAtIndex:0] isEqualToString:userName]) {
            return false;
        }
    }
    return true;
}

- (NSString *) userList {
    
    NSMutableArray *userList = [NSMutableArray array];
    
    for (NSArray *item in self->users.allValues) {
        NSDictionary *name = [NSDictionary dictionaryWithObjectsAndKeys:[item objectAtIndex:0], @"name", [item objectAtIndex:1], @"img", nil];
        [userList addObject:name];
    }
    
    NSDictionary *results = [NSDictionary dictionaryWithObject:userList forKey:@"users"];
    
    return [self stringFromDictionary:results];
}

- (BOOL) obsceneExpression : (NSString *) message {
    
    NSRange rangeValue1 = [message rangeOfString:@"редиска" options:NSCaseInsensitiveSearch];
    NSRange rangeValue2 = [message rangeOfString:@"ботаник" options:NSCaseInsensitiveSearch];
    NSRange rangeValue3 = [message rangeOfString:@"гейтс" options:NSCaseInsensitiveSearch];
    
    if (rangeValue1.location != NSNotFound || rangeValue2.location != NSNotFound || rangeValue3.location != NSNotFound) {
        return true;
    }
    return false;
}

- (NSString *) messagesListFromID : (NSInteger) ID {
    
    NSMutableArray *messagesList = [NSMutableArray array];
    
    for (NSNumber *number in self->messages) {
        NSDictionary *dictionary = nil;
        
        @synchronized (self) {
            dictionary = [self->messages objectForKey:number];
        }
        
        NSInteger msgID = [[dictionary objectForKey:@"ID"] integerValue];
        if (msgID > ID) {
            [messagesList addObject:dictionary];
        }
    }
    NSDictionary *results = [NSDictionary dictionaryWithObject:messagesList forKey:@"messages"];
    
    return [self stringFromDictionary:results];
}

- (void) deleteUser : (int) descriptor {
    
    NSNumber *key = [NSNumber numberWithInt:descriptor];
    
    if ([self->users objectForKey:key] != nil) {
        @synchronized (self) {
            [self->users removeObjectForKey:key];
        }
    }
}

@end
