//
//  RecordMusicInfo.h
//  ClairAudient
//
//  Created by vedon on 23/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface RecordMusicInfo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * makeTime;

@end
