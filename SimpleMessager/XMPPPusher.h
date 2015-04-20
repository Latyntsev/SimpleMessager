//
//  XMPPPusher.h
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/20/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMModelMessage.h"

@interface XMPPPusher : NSObject

- (instancetype)initWithHost:(NSString *)host login:(NSString *)login andPassword:(NSString *)password;

- (void)connecnt;
- (void)joinRoom:(NSString *)roomName withNickName:(NSString *)nickName;
- (BOOL)isConnected;

typedef void(^XMPPPusherConnectionHandlerComplitionBlock)(XMPPPusher *pusher, BOOL connected);
typedef void(^XMPPPusherMessageHandlerComplitionBlock)(XMPPPusher *pusher, SMModelMessage *message);
typedef void(^XMPPPusherErrorHandlerComplitionBlock)(XMPPPusher *pusher, NSError *error);

@property (nonatomic,copy) XMPPPusherConnectionHandlerComplitionBlock connectionHandler;
@property (nonatomic,copy) XMPPPusherMessageHandlerComplitionBlock messageHandler;
@property (nonatomic,copy) XMPPPusherErrorHandlerComplitionBlock errorHandler;

- (void)sendMessage:(SMModelMessage *)message;

@end
