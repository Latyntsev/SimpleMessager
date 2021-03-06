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


@interface SMConversationViewController () <UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) XMPPPusher *pusher;
@property (nonatomic,strong) NSMutableArray *data;
@property (nonatomic,strong) NSOperationQueue *queue;

@end

@implementation SMConversationViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.queue = [[NSOperationQueue alloc] init];
    self.queue.maxConcurrentOperationCount = 1;
    
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
    [self.activityIndicator startAnimating];
    self.pusher = [[XMPPPusher alloc] initWithHost:XMPP_HOST
                                             login:XMPP_LOGIN
                                       andPassword:XMPP_PASSWORD];
    
    [self.pusher setConnectionHandler:^(XMPPPusher *pusher, BOOL connected) {
        if (connected) {
            [wself.data removeAllObjects];
            [pusher joinRoom:@"test" withNickName:wself.nickName];
            [wself.activityIndicator stopAnimating];
        } else {
            [wself.activityIndicator startAnimating];
        }
    }];
    
    
    
    [self.pusher setMessageHandler:^(XMPPPusher *pusher, SMModelMessage *message) {
        [wself.data insertObject:message atIndex:wself.data.count];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:wself.data.count-1 inSection:0];
        
        [wself.tableView insertRowsAtIndexPaths:@[indexPath]
                               withRowAnimation:UITableViewRowAnimationNone];
        
        [wself.tableView scrollToRowAtIndexPath:indexPath
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:YES];
    }];
    
    [self.pusher setErrorHandler:^(XMPPPusher *pusher, NSError *error) {
    
    }];
    
    [self.pusher connecnt];
}

#pragma mark - Actions
- (IBAction)onClickSend:(id)sender {
    if (self.messageTextField.text.length == 0) {
        return;
    }
    
    SMModelMessage *messgae = [[SMModelMessage alloc] init];
    messgae.body = self.messageTextField.text;
    messgae.from = self.nickName;
    
    
    [self.queue addOperationWithBlock:^{
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.pusher sendMessage:messgae];
        }];
    }];
    
    self.messageTextField.text = @"";
}

- (IBAction)onClickAddAttachment:(id)sender {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Send Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Librart",@"Camera", nil];
    
    [actionSheet showInView:self.view];
    
    
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerControllerSourceType type = buttonIndex;
    
    UIImagePickerController *pickerLibrary = [[UIImagePickerController alloc] init];
    pickerLibrary.sourceType = type;
    pickerLibrary.delegate = self;
    [self presentViewController:pickerLibrary animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    
    [self.activityIndicator startAnimating];
    NSData *data = UIImageJPEGRepresentation(image, 0.6);
    
    
    [self.queue addOperationWithBlock:^{
        PFObject *fileObject = [PFObject objectWithClassName:@"File"];
        fileObject[@"file"] = [PFFile fileWithName:@"image.jpg" data:data];
        if ([fileObject save]) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.activityIndicator stopAnimating];
                SMModelMessage *messgae = [[SMModelMessage alloc] init];
                messgae.body = [fileObject objectId];
                messgae.from = self.nickName;
                messgae.mediaType = SMMessageMediaType_image;
                [self.pusher sendMessage:messgae];
                self.messageTextField.text = @"";
            }];
        }
    }];
    
    
    [picker dismissViewControllerAnimated:YES completion:nil];
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

- (NSString *)cellIdentifierWithMediaType:(SMMessageMediaTypes)mediaType {
    switch (mediaType) {
        case SMMessageMediaType_text:
            return @"SMConversationMessageCell_text";
            break;
            
        case SMMessageMediaType_image:
            return @"SMConversationMessageCell_image";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SMModelMessage *message = self.data[indexPath.row];
    NSString *cellIdentifier = [self cellIdentifierWithMediaType:message.mediaType];
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell setMessage:message soft:YES];
    [cell.contentView layoutIfNeeded];
    CGSize size = [cell.contentView systemLayoutSizeFittingSize:(CGSize){tableView.frame.size.width,10}];
    cell.frame = (CGRect){cell.frame.origin,size};
    return size.height + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SMModelMessage *message = self.data[indexPath.row];
    NSString *cellIdentifier = [self cellIdentifierWithMediaType:message.mediaType];
    SMConversationMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    [cell setMessage:message];
    return cell;
}

@end
