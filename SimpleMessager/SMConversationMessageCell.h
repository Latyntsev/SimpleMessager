//
//  SMConversationMessageCell.h
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMModelMessage;

@interface SMConversationMessageCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messgaeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

- (void)setMessage:(SMModelMessage *)message;
- (void)setMessage:(SMModelMessage *)message soft:(BOOL)soft;

@end
