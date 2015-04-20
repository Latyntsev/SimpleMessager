//
//  SMModelMessage.h
//  SimpleMessager
//
//  Created by Oleksandr Latyntsev on 4/20/15.
//  Copyright (c) 2015 Non. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMPPMessage;

@interface SMModelMessage : NSObject

typedef NS_ENUM(NSInteger, SMMessageMediaTypes) {
    SMMessageMediaType_text,
    SMMessageMediaType_image
};

@property (nonatomic,strong) NSDate *date;
@property (nonatomic,strong) NSString *from;
@property (nonatomic,strong) NSString *body;
@property (nonatomic) SMMessageMediaTypes mediaType;

+ (instancetype)messageFromXMPPMessage:(XMPPMessage *)message;
- (XMPPMessage *)toXMPPMessage;



@end
