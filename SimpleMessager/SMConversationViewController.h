//
//  SMConversationViewController.h
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMConversationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBoxBottmMargin;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
