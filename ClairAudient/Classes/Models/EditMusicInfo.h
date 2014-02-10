//
//  EditMusicInfo.h
//  ClairAudient
//
//  Created by vedon on 10/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EditMusicInfo : NSManagedObject

@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * localFilePath;
@property (nonatomic, retain) NSString * length;
@property (nonatomic, retain) NSNumber * isFavirote;
@property (nonatomic, retain) NSString * makeTime;
@property (nonatomic, retain) NSString * title;

@end
