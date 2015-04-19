//
//  SMInboxViewController.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMInboxViewController.h"
#import <Parse/Parse.h>

NSString *const kShowConversationSegue = @"ShowConversationSegue";

@implementation SMInboxViewController

- (IBAction)onClickJoinRoom:(id)sender {
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"What is Your name?"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles:@"Confirm",nil];
    
    alerView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alerView textFieldAtIndex:0].text = [PFUser currentUser][@"userName"];
    [alerView textFieldAtIndex:0].placeholder = @"Enter Your name";
    [alerView show];
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView {
    
    return ([alertView textFieldAtIndex:0].text.length > 0);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    
    NSString *userName = [alertView textFieldAtIndex:0].text;
    PFUser *user = [PFUser currentUser];
    user[@"userName"] = userName;
    
    [user saveInBackground];
    
    [self performSegueWithIdentifier:kShowConversationSegue sender:nil];
}


@end
