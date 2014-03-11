//
//  EditMusicInfo.h
//  ClairAudient
//
//  Created by vedon on 11/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EditMusicInfo : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * isFavirote;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSString * localPath;
@property (nonatomic, retain) NSString * makeTime;
@property (nonatomic, retain) NSString * title;

@end
