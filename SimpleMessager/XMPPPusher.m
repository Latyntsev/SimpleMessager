//
//  XMPPPusher.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/20/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "XMPPPusher.h"
#import "XMPPFramework.h"
#import "XMPPReconnect.h"
#import "XMPPMessage.h"

@interface XMPPPusher ()

@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;

@property (nonatomic,strong) NSString *host;
@property (nonatomic,strong) NSString *login;
@property (nonatomic,strong) NSString *password;
@property (nonatomic,strong) NSString *roomJID;

@end


@implementation XMPPPusher

- (instancetype)initWithHost:(NSString *)host login:(NSString *)login andPassword:(NSString *)password {
    self = [super init];
    if (self) {
        
        self.host = host;
        self.login = login;
        self.password = password;
        
        self.xmppStream = [[XMPPStream alloc] init];
        self.xmppReconnect = [[XMPPReconnect alloc] init];
        [self.xmppReconnect activate:self.xmppStream];
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
#if !TARGET_IPHONE_SIMULATOR
        self.xmppStream.enableBackgroundingOnSocket = YES;
#endif
    }
    return self;
}

- (NSString *)JID {
    
    return [NSString stringWithFormat:@"%@@%@",self.login,self.host];
}

- (void)connecnt {
    
    if (!self.isConnected) {
        [self.xmppStream setMyJID:[XMPPJID jidWithString:self.JID]];
        NSError *error = nil;
        if (![self.xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
            
        }
    }
}

- (void)joinRoom:(NSString *)roomName withNickName:(NSString *)nickName {
    
    XMPPPresence *presence = [NSXMLElement elementWithName:@"presence"];
    self.roomJID = [NSString stringWithFormat:@"%@@conference.%@",roomName,self.host];
    NSString *roomJIDWithNickName = [NSString stringWithFormat:@"%@/%@",self.roomJID,nickName];
    
    [presence addAttributeWithName:@"to" stringValue:roomJIDWithNickName];
    NSXMLElement *x = [NSXMLElement elementWithName:@"x" xmlns:@"http://jabber.org/protocol/muc"];
    NSXMLElement *history = [NSXMLElement elementWithName:@"history"];
    [history addAttributeWithName:@"maxstanzas" stringValue:@"3"];
    [x addChild:history];
    [presence addChild:x];
    [self.xmppStream sendElement:presence];
}

- (BOOL)isConnected {
    
    return self.xmppStream.isConnected;
}

- (void)sendMessage:(SMModelMessage *)message {
    
    XMPPMessage *messageData = [message toXMPPMessage];
    
    [messageData addAttributeWithName:@"to" stringValue:self.roomJID];
    [messageData addAttributeWithName:@"type" stringValue:@"groupchat"];
    
    [self.xmppStream sendElement:messageData];
}

#pragma mark XMPPStream Delegate
- (void)xmppStream:(XMPPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    
    NSString *expectedCertName = [self.xmppStream.myJID domain];
    if (expectedCertName)
    {
        settings[(NSString *) kCFStreamSSLPeerName] = expectedCertName;
    }
    
    settings[GCDAsyncSocketManuallyEvaluateTrust] = @(YES);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    
    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{
        
        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);
        
        if (status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified)) {
            completionHandler(YES);
        }
        else {
            completionHandler(NO);
        }
    });
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    NSError *error = nil;
    if (![self.xmppStream authenticateWithPassword:self.password error:&error]) {
        if (self.errorHandler) {
            self.errorHandler(self,error);
        }
    }
    
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {

    if (self.connectionHandler) {
        self.connectionHandler(self,true);
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    
    if (self.errorHandler) {
        NSError *theError = [NSError errorWithDomain:@"com.app.XMPPPusher" code:1 userInfo:@{NSUnderlyingErrorKey:error}];
        self.errorHandler(self,theError);
    }
}

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {

    if (self.messageHandler) {
        self.messageHandler(self, [SMModelMessage messageFromXMPPMessage:message]);
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error {
    
    if (self.errorHandler) {
        self.errorHandler(self,error);
    }
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    
    if (self.errorHandler) {
        self.errorHandler(self,error);
    }
}

@end
