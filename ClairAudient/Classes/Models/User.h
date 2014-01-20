//
//  User.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "BaseModel.h"

@interface User : BaseModel
@property (nonatomic,strong) NSString * birthday;
@property (nonatomic,strong) NSString * findQuestion;
@property (nonatomic,strong) NSString * findAnswer;
@property (nonatomic,strong) NSString * postCode;
@property (nonatomic,strong) NSString * workUnit;
@property (nonatomic,strong) NSString * passWord;
@property (nonatomic,strong) NSString * integral;
@property (nonatomic,strong) NSString * hw_id;
@property (nonatomic,strong) NSString * address;
@property (nonatomic,strong) NSString * email;
@property (nonatomic,strong) NSString * userName;
@property (nonatomic,strong) NSString * role;
@property (nonatomic,strong) NSString * workYears;
@property (nonatomic,strong) NSString * qq;
+ (void)saveToLocal:(User *)user;
+ (User *)userFromLocal;
@end
