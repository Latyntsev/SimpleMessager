//
//  SMConversationMessageCell.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMConversationMessageCell.h"
#import "SMModelMessage.h"

@implementation SMConversationMessageCell

- (void)setMessage:(SMModelMessage *)message {
    
    static NSDateFormatter *df;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"mm/dd/yyyy HH:mm";
    }
    
    self.dateLabel.text = [df stringFromDate:message.date];
    self.userNameLabel.text = message.from;
    self.messgaeLabel.text = message.body;
}

@end
