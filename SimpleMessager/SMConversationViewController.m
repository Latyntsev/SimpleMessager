//
//  SMConversationViewController.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMConversationViewController.h"
#import "SMConversationMessageCell.h"

#import <Parse/Parse.h>

@interface SMConversationViewController () <UITableViewDelegate, UITableViewDataSource>

@end

@implementation SMConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kayboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kayboadWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}


#pragma mark - Actions
- (IBAction)onClickAddAttachment:(id)sender {
    
}

- (IBAction)onClickSend:(id)sender {
    [self.messageTextField resignFirstResponder];
}

#pragma mark - Keyboard Notifications
- (void)kayboadWillShow:(NSNotification *)notification {
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.messageBoxBottmMargin.constant = keyboardFrame.size.height;
        [self.view layoutIfNeeded];
    }];
    
    
}

- (void)kayboadWillHide:(NSNotification *)notification {
   
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        
         self.messageBoxBottmMargin.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 12;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMConversationMessageCell"];
    
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMConversationMessageCell"
                                                                      forIndexPath:indexPath];
    
    
    return cell;
}

@end
