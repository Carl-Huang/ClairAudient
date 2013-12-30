//
//  IO.m
//  HWSDK
//
//  Created by Carl_Huang on 13-11-18.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import "IO.h"

@implementation IO


+(NSString *)generateRndString
{
    NSDate * date = [NSDate date];
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmssSSS";
    formatter.locale = [NSLocale currentLocale];
    NSString * dateString = [formatter stringFromDate:date];
    //    dateString = [dateString stringByAppendingFormat:@"%lu",random()];
    return dateString;
}

+(NSString *)documentPath
{
    NSArray * files = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * document  = [files objectAtIndex:0];
    
    return document;
}

+(NSURL *)URLForResource:(NSString *)name inDirectory:(NSString *)directory
{
    NSString * doc = [[self class] documentPath];
    NSString * directoryPath;
    if(directory != nil)
    {
        directoryPath = [doc stringByAppendingPathComponent:directory];
    }
    else
    {
        directoryPath = doc;
    }
    NSString * filePath = [directoryPath stringByAppendingPathComponent:name];
    return [NSURL fileURLWithPath:filePath];
}

+ (BOOL)writeImageToDocument:(NSData *)data
{
    
    if(!data){
        NSLog(@"The image data is nil.");
        return NO;
    }
    
    NSString * docPath = [[self class] documentPath];
    NSString * fileName = [[[self class] generateRndString] stringByAppendingPathExtension:@"png"];
    NSString * filePath = [docPath stringByAppendingPathComponent:fileName];
    if([data writeToFile:filePath atomically:YES])
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)writeImageToDirectory:(NSString *)directory withData:(NSData *)data
{
    if(!data){
        NSLog(@"The data is nil.");
        return NO;
    }
    
    NSString * directoryPath = [[[self class] documentPath] stringByAppendingPathComponent:directory];
    NSString * fileName = [[[self class] generateRndString] stringByAppendingPathExtension:@"png"];
    NSString * filePath = [directoryPath stringByAppendingPathComponent:fileName];
    if([data writeToFile:filePath atomically:YES])
    {
        
        return YES;
    }
    
    return NO;
    
}


+ (BOOL)createDirectoryInDocument:(NSString *)dicrectoryName
{
    if([dicrectoryName length] == 0)
    {
        return NO;
    }
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * dicrectoryPath = [[[self class] documentPath] stringByAppendingPathComponent:dicrectoryName];
    BOOL isDirectory;
    if([fileManager fileExistsAtPath:dicrectoryPath isDirectory:&isDirectory])
    {
        if(isDirectory)
        {
            return NO;
        }
    }
    
    NSError * createError;
    BOOL result = [fileManager createDirectoryAtPath:dicrectoryPath withIntermediateDirectories:YES attributes:nil error:&createError];
    
    if(!result)
    {
        NSLog(@"Create directory error:%@",createError);
    }
    return result;
    
}



+ (BOOL)createFileInDirectory:(NSString *)directory withFileName:(NSString *)fileName
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * docPath = [[self class] documentPath];
    NSString * directoryPath = [docPath stringByAppendingPathComponent:directory];
    BOOL isDir ;
    if(![fileManager fileExistsAtPath:directoryPath isDirectory:&isDir])
    {
        [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    else
    {
        if(!isDir)
        {
            [fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    NSString * filePath = [directoryPath stringByAppendingPathComponent:fileName];
    
    if([fileManager fileExistsAtPath:filePath])
    {
        return YES;
    }
    else
    {
        return [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    }
}

+(NSArray *)fecthFilesInDocPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * docPath = [[self class] documentPath];
    NSArray * properties = [NSArray arrayWithObject:NSURLAttributeModificationDateKey];

    NSDirectoryEnumerator * directoryEnum = [fileManager enumeratorAtURL:[NSURL URLWithString:docPath] includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants errorHandler:nil];
    NSMutableArray * allFiles = [NSMutableArray array];
    for(NSURL * URL in directoryEnum)
    {
        
        [allFiles addObject:URL];
        
    }
    return (NSArray *)allFiles;
    
}




+ (NSArray *)fetchFilesInPath:(NSString *)path
{
    NSMutableArray * allFiles = [NSMutableArray array];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * docPath = [[self class] documentPath];
    NSString * directoryPath = [docPath stringByAppendingPathComponent:path];
    BOOL isDir;
    if(![fileManager fileExistsAtPath:directoryPath isDirectory:&isDir])
    {
        NSLog(@"File is not exists.");
        return allFiles;
    }
    else
    {
        if(!isDir)
        {
            NSLog(@"File is not directory.");
            return allFiles;
        }
    }
    
    NSString * escapeStr = [directoryPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSArray * properties = [NSArray arrayWithObject:NSURLAttributeModificationDateKey];
    NSArray * files = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:escapeStr] includingPropertiesForKeys:properties options:NSDirectoryEnumerationSkipsSubdirectoryDescendants|NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants error:nil];

    if([files count] == 0)
    {
        return allFiles;
    }
    for(NSURL * url in files)
    {
        [allFiles addObject:[url path]];
    }
    return (NSArray *)allFiles;
}



+ (NSArray *)fetchSubDirectoryInDoc
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * docPath = [[self class] documentPath];
    NSArray * files = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:docPath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles|NSDirectoryEnumerationSkipsPackageDescendants error:nil];
    
    NSMutableArray * directorys = [NSMutableArray array];
    
    for (NSURL * url in files) {
        
        BOOL isDirectory;
        if([fileManager fileExistsAtPath:url.path isDirectory:&isDirectory] && isDirectory)
        {
            [directorys addObject:[url lastPathComponent]];
        }
        
        
    }
    
    return (NSArray *)directorys;
}




@end
