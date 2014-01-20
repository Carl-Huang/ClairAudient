//
//  BaseModel.m
//  ClairAudient
//
//  Created by Carl on 14-1-19.
//  Copyright (c) 2014年 helloworld. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

@implementation BaseModel
+ (NSDictionary *)toDictionary:(id)object
{
    if(!object)
    {
        return nil;
    }
    NSArray * properties = [[self class] propertiesName:[object class]];
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    for(NSString * property in properties)
    {
        NSString * value = [object valueForKey:property];
        [dic setValue:value forKey:property];
    }
    return dic;
    
}
+ (id)fromDictionary:(NSDictionary *)info withClass:(Class)cls
{
    id object = [[self class] mapModel:info withClass:cls];
    return object;
}

/**
 @desc 返回类的属性列表
 @param 类对应的class
 @return NSArray 属性列表
 */
+ (NSArray *)propertiesName:(Class)cls
{
    if(cls == nil) return nil;
    unsigned int outCount,i;
    objc_property_t * properties = class_copyPropertyList(cls, &outCount);
    NSMutableArray * list = [NSMutableArray arrayWithCapacity:outCount];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        if(propertyName && [propertyName length] != 0)
        {
            [list addObject:propertyName];
        }
    }
    return list;
}


+ (id)mapModel:(id)reponseObject withClass:(Class)cls
{
    if (!reponseObject) {
        return nil;
    }
    id model  = [[cls alloc] init];
    NSArray * properties = [[self class] propertiesName:cls];
    for(NSString * property in properties)
    {

        id value = [reponseObject valueForKey:property];
        if(![value isKindOfClass:[NSNull class]])
        {
            if(![value isKindOfClass:[NSString class]])
            {
                [model setValue:[value stringValue] forKey:property];
            }
            else
            {
                [model setValue:value forKey:property];
            }
        }
    }
    return model;
}

@end
