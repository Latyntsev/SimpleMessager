//
//  SMModelMessage.m
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/20/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import "SMModelMessage.h"
#import "NSXMLElement+XMPP.h"
#import "XMPPmessage.h"

@implementation SMModelMessage

- (instancetype)init {
    self = [super init];
    if (self) {
        self.date = [NSDate date];
    }
    
    return self;
}

+ (instancetype)messageFromXMPPMessage:(XMPPMessage *)message {
    SMModelMessage *instance = [[SMModelMessage alloc] init];
    
    
    NSArray *dataArray = [message elementsForName:@"metaData"];
    instance.body = [message body];
    if (dataArray.count > 0){
        XMPPElement *data = [dataArray firstObject];
        
        instance.from = [[data attributeForName:@"from"] stringValue];
        instance.date = [NSDate dateWithTimeIntervalSince1970:[[[data attributeForName:@"date"] stringValue] doubleValue]];
        instance.mediaType = [[[data attributeForName:@"mediaType"] stringValue] integerValue];
    }
    
    return instance;
}

- (XMPPMessage *)toXMPPMessage {
    
    XMPPMessage *messageData = [XMPPMessage message];
    NSXMLElement *metaData = [NSXMLElement elementWithName:@"metaData"];
    [messageData addBody:self.body];
    
    [metaData addAttributeWithName:@"from" stringValue:self.from];
    [metaData addAttributeWithName:@"date" doubleValue:self.date.timeIntervalSince1970];
    [metaData addAttributeWithName:@"mediaType" integerValue:self.mediaType];
    
    [messageData addChild:metaData];
    
    return messageData;
}

@end
