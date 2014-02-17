//
//  DownloadMusicInfo.h
//  ClairAudient
//
//  Created by vedon on 17/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DownloadMusicInfo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * makeTime;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * isFavorite;

@end
