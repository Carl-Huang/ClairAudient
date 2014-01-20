//
//  BaseModel.h
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
+ (NSDictionary *)toDictionary:(id)object;
+ (id)fromDictionary:(NSDictionary *)info withClass:(Class)cls;
@end
