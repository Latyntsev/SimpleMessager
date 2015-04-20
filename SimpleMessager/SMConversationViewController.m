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
#import "XMPPPusher.h"


extern NSString *const XMPP_HOST;
extern NSString *const XMPP_LOGIN;
extern NSString *const XMPP_PASSWORD;


@interface SMConversationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong) XMPPPusher *pusher;
@property (nonatomic,strong) NSMutableArray *data;

@end

@implementation SMConversationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [NSMutableArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kayboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(kayboadWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
    __weak typeof(self) wself = self;
    self.pusher = [[XMPPPusher alloc] initWithHost:XMPP_HOST
                                             login:XMPP_LOGIN
                                       andPassword:XMPP_PASSWORD];
    
    [self.pusher setConnectionHandler:^(XMPPPusher *pusher, BOOL connected) {
        if (connected) {
            [wself.data removeAllObjects];
            [pusher joinRoom:@"test" withNickName:[PFUser currentUser][@"userName"]];
        }
    }];
    
    [self.pusher setMessageHandler:^(XMPPPusher *pusher, SMModelMessage *message) {
        [wself.data insertObject:message atIndex:wself.data.count];
        [wself.tableView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:wself.data.count-1 inSection:0];
        [wself.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }];
    
    [self.pusher setErrorHandler:^(XMPPPusher *pusher, NSError *error) {
    
    }];
    
    [self.pusher connecnt];
}


#pragma mark - Actions
- (IBAction)onClickAddAttachment:(id)sender {
    
}

- (IBAction)onClickSend:(id)sender {
    if (self.messageTextField.text.length == 0) {
        return;
    }
    
    SMModelMessage *messgae = [[SMModelMessage alloc] init];
    messgae.body = self.messageTextField.text;
    messgae.from = [PFUser currentUser][@"userName"];
    
    [self.pusher sendMessage:messgae];
    self.messageTextField.text = @"";
}

#pragma mark - Keyboard Notifications
- (void)kayboadWillShow:(NSNotification *)notification {
    
    NSTimeInterval duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.messageBoxBottmMargin.constant = keyboardFrame.size.height;
        [self.view layoutIfNeeded];
        if (self.data.count > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.data.count-1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
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
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMConversationMessageCell"];
    
    SMModelMessage *message = self.data[indexPath.row];
    [cell setMessage:message];
    [cell.contentView layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:(CGSize){tableView.frame.size.width,10}];
    
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SMConversationMessageCell"
                                                                      forIndexPath:indexPath];
    
    SMModelMessage *message = self.data[indexPath.row];
    [cell setMessage:message];
    return cell;
}

@end
