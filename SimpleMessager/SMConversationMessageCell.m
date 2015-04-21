//
//  SMConversationMessageCell.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMConversationMessageCell.h"
#import "SMModelMessage.h"
#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>

@interface SMConversationMessageCell ()

@property (nonatomic,weak) SMModelMessage *message;

@end

@implementation SMConversationMessageCell

- (void)setMessage:(SMModelMessage *)message {
    [self setMessage:message soft:NO];
}

- (void)setMessage:(SMModelMessage *)message soft:(BOOL)soft {
    
    if (_message == message) {
        return;
    }
    
    _message = message;
    static NSDateFormatter *df;
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"mm/dd/yyyy HH:mm";
    }
    
    self.dateLabel.text = [df stringFromDate:message.date];
    self.userNameLabel.text = message.from;
    
    switch (message.mediaType) {
        case SMMessageMediaType_text:
            self.messgaeLabel.text = message.body;
            break;
            
        case SMMessageMediaType_image: {
            [self.loadingIndicator startAnimating];
            self.photoImageView.layer.cornerRadius = 5;
            self.photoImageView.image = nil;
            if (!soft) {
                void(^LoadImage)() = ^() {
                    PFFile *file = message.file[@"file"];
                    if (self.message != message) {
                        return;
                    }
                    
                    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                        if (self.message != message) {
                            return;
                        }
                        if (!error) {
                            UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                            self.photoImageView.image = image;
                            [self.loadingIndicator stopAnimating];
                        }
                    }];
                };
                
                if (message.file) {
                    
                    LoadImage();
                    
                } else {
                    
                    PFQuery *query = [PFQuery queryWithClassName:@"File"];
                    [query getObjectInBackgroundWithId:message.body block:^(PFObject *object, NSError *error) {
                        if (error) {
                            return;
                        }
                        
                        message.file = object;
                        
                        LoadImage();
                    }];
                }
            }
        }
            
            break;
    }
    
    
}

@end
