//
//  SMInboxViewController.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/19/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMInboxViewController.h"
#import "SMConversationViewController.h"

NSString *const kShowConversationSegue = @"ShowConversationSegue";

@interface SMInboxViewController ()

@property (nonatomic,strong) NSString *nickName;

@end

@implementation SMInboxViewController

@dynamic nickName;

- (IBAction)onClickJoinRoom:(id)sender {
    
    UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"What is Your name?"
                                                       message:nil
                                                      delegate:self
                                             cancelButtonTitle:@"Dismiss"
                                             otherButtonTitles:@"Confirm",nil];
    
    alerView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alerView textFieldAtIndex:0].text = self.nickName;
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
    
    NSString *nickName = [alertView textFieldAtIndex:0].text;
    if (nickName.length > 0) {
        
        self.nickName = nickName;
        [self performSegueWithIdentifier:kShowConversationSegue
                                  sender:nickName];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kShowConversationSegue]) {
        SMConversationViewController *vc = segue.destinationViewController;
        vc.nickName = sender;
    }
}

- (void)setNickName:(NSString *)nickName {
    [[NSUserDefaults standardUserDefaults] setValue:nickName forKey:@"nickName"];
}

- (NSString *)nickName {
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"nickName"];
}


@end
