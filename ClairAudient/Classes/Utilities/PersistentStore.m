//
//  PersistentStore.m
//  ClairAudient
//
//  Created by vedon on 9/12/13.
//  Copyright (c) 2013 helloworld. All rights reserved.
//

#import "PersistentStore.h"
#import <objc/runtime.h>

@implementation PersistentStore
+(void)createAndSaveWithObject:(Class)objClass params:(NSDictionary *)params
{
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList(objClass, &outCount);
    id obj = [objClass  MR_createEntity];
    for (int i =0; i<outCount; i++) {
        objc_property_t property = properties[i];
        NSString * propertyName = [NSString stringWithUTF8String:property_getName(property)];
        [obj setValue:[params objectForKey:propertyName] forKey:propertyName];
    }
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
    
}

+(NSArray *)getObjectWithType:(Class)type Key:(NSString *)key Value:(NSString *)value
{
    NSArray *tempArray = [type MR_findByAttribute:key withValue:value];
    return tempArray;
}

+(NSArray *)getAllObjectWithType:(Class)type
{
    NSArray * tempArray = [type MR_findAll];
    return tempArray;
}

+(id)getLastObjectWithType:(Class)type
{
    NSArray * tempArray = [self getAllObjectWithType:type];
    if ([tempArray count]) {
        id lastObj = [tempArray lastObject];
        return lastObj;
    }else
    {
        return nil;
    }
}


+(void)updateObject:(id)obj Key:(NSString *)key Value:(NSString *)value
{
    [obj setValue:value forKey:key];
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
}

+(BOOL)deleteObje:(id)obj
{
   BOOL isSuccess = [obj MR_deleteEntity];
    
   [[NSManagedObjectContext MR_defaultContext]MR_saveToPersistentStoreAndWait];
    return isSuccess;
}

+(void)save
{
    [[NSManagedObjectContext MR_defaultContext]MR_saveOnlySelfAndWait];
}
@end
