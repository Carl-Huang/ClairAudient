//
//  VoiceComment.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "BaseModel.h"

@interface VoiceComment : BaseModel
@property (nonatomic,strong) NSString * quote_content;
@property (nonatomic,strong) NSString * content;
@property (nonatomic,strong) NSString * hw_id;
@property (nonatomic,strong) NSString * vl_id;
@property (nonatomic,strong) NSString * user_id;
@end
