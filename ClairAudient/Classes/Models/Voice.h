//
//  Voice.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "BaseModel.h"

@interface Voice : BaseModel
@property (nonatomic,strong) NSString * download_num;
@property (nonatomic,strong) NSString * state;
@property (nonatomic,strong) NSString * sampling_rate;
@property (nonatomic,strong) NSString * url;
@property (nonatomic,strong) NSString * hw_id;
@property (nonatomic,strong) NSString * upload_time;
@property (nonatomic,strong) NSString * username;
@property (nonatomic,strong) NSString * time;
@property (nonatomic,strong) NSString * vl_name;
@property (nonatomic,strong) NSString * vl_explain;
@property (nonatomic,strong) NSString * priority;
@property (nonatomic,strong) NSString * vlt_id;
@property (nonatomic,strong) NSString * user_id;
@property (nonatomic,strong) NSString * parent_id;
@property (nonatomic,strong) NSString * bit_rate;
@end
