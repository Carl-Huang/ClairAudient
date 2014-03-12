//
//  MusicCommentItem.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
//{"quote_content":"","content":"咯麽","id":5,"vl_id":378,"username":"qqq","user_id":18,"date":1394095731788,"recive_name":""
@interface MusicCommentItem : NSObject
@property (strong ,nonatomic) NSString * quote_content;
@property (strong ,nonatomic) NSString * content;
@property (strong ,nonatomic) NSString * ID;
@property (strong ,nonatomic) NSString * vl_id;
@property (strong ,nonatomic) NSString * username;
@property (strong ,nonatomic) NSString * user_id;
@property (strong ,nonatomic) NSString * date;
@property (strong ,nonatomic) NSString * recive_name;
@end
