//
//  PersistentStore.h
//  ClairAudient
//
//  Created by vedon on 9/12/13.
//  Copyright (c) 2013 helloworld. All rights reserved.
//


/*
    在.pch 文件添加头文件，否则需要添加以下头文件：
    #import "CoreData+MagicalRecord.h"
 
 */

#import<Foundation/Foundation.h>

@interface PersistentStore : NSObject

/**
@desc 添加数据，并保存到数据库
*/
+(void)createAndSaveWithObject:(Class)objClass params:(NSDictionary *)params;

/**
 @desc 根据key 获取指定类型的值
 */
+(NSArray *)getObjectWithType:(Class)type Key:(NSString *)key Value:(NSString *)value;

/**
 @desc 获取所有类型的对象
 */
+(NSArray *)getAllObjectWithType:(Class)type;

/**
 @desc 获取表中最后一条数据
 */
+(id)getLastObjectWithType:(Class)type;

/**
 @desc 根据对象的key ,更新对象
 */
+(void)updateObject:(id)obj Key:(NSString *)key Value:(NSString *)value;

/**
 @desc 删除对象
 */
+(BOOL)deleteObje:(id)obj;

+(void)save;
@end
