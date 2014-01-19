//
//  Catalog.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "BaseModel.h"

@interface Catalog : BaseModel
@property (nonatomic,strong) NSString * hw_id;
@property (nonatomic,strong) NSString * vlt_name;
@property (nonatomic,strong) NSString * vlt_id;
@property (nonatomic,strong) NSString * parent_id;
@end
