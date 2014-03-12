//
//  AsynCycleView.m
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AsynCycleView.h"
#import "CycleScrollView.h"
#import "HttpService.h"

@interface AsynCycleView()
{
    CycleScrollView * autoScrollView;
}
@property (strong ,nonatomic) NSMutableArray * placeHolderImages;
@property (strong ,nonatomic) NSMutableArray * networkImages;
@property (strong ,nonatomic) UIImageView * placeHoderImage;
@end
@implementation AsynCycleView
@synthesize placeHolderImages,networkImages;

-(id)initAsynCycleViewWithFrame:(CGRect)rect
               placeHolderImage:(UIImageView *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
   replaceWithNetworkImagesLink:(NSArray *)networkImages
                          addTo:(UIView *)parentView
{
    self = [super init];
    if (self) {
        __weak AsynCycleView * weakSelf =self;
        _placeHoderImage = image;
        for (int i =0; i<numOfPlaceHoderImages; ++i) {
            if (placeHolderImages) {
                placeHolderImages = [NSMutableArray array];
            }
            [placeHolderImages addObject:image];
        }
        
        autoScrollView = [[CycleScrollView alloc] initWithFrame:rect animationDuration:2];
        autoScrollView.backgroundColor = [UIColor clearColor];
        autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
            return weakSelf.placeHolderImages[pageIndex];
        };
        autoScrollView.totalPagesCount = ^NSInteger(void){
            return [weakSelf.placeHolderImages count];
        };
        autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
            NSLog(@"点击了第%ld个",(long)pageIndex);
        };
        [parentView addSubview:autoScrollView];
    }
    return self;
}

-(void)updateNetworkImagesLink:(NSArray *)links
{
    __weak AsynCycleView * weakSelf =self;
    [self resetThePlaceImages:links];
    
    for (int i =0; i<[links count]; ++i) {
        NSString * imgStr = [links objectAtIndex:i];
        if (![imgStr isKindOfClass:[NSNull class]]) {
            [weakSelf getImage:imgStr withIndex:i];
        }
    }
}

-(void)resetThePlaceImages:(NSArray *)links
{
    __weak AsynCycleView * weakSelf =self;
    if ([links count ] > [weakSelf.placeHolderImages count]) {
        for (int i = [weakSelf.placeHolderImages count]; i < [links count]; i ++) {
            [weakSelf.placeHolderImages addObject:_placeHoderImage];
        }
    }else
    {
        for (int i = [links count]; i < [weakSelf.placeHolderImages count]; i ++) {
            [weakSelf.placeHolderImages removeObjectAtIndex:i];
        }
    }
    
    networkImages = [placeHolderImages mutableCopy];
}

-(void)getImage:(NSString *)imgStr withIndex:(NSInteger)index
{
    __weak AsynCycleView * weakSelf = self;
    
    [[HttpService sharedInstance]getImageWithResourcePath:imgStr completedBlock:^(id object) {
        if (object) {
            UIImageView * imageView = nil;
            if ([object isKindOfClass:[UIImage class]]) {
                imageView = [[UIImageView alloc]initWithImage:object];
                [weakSelf.networkImages replaceObjectAtIndex:index withObject:imageView];
                
                
                [weakSelf updateAutoScrollViewItem];
            
            }
        }
    } failureBlock:^(NSError * error) {
        ;
    }];
}

-(void)updateAutoScrollViewItem
{
    self.placeHolderImages = [self.networkImages mutableCopy];
    
    __weak AsynCycleView * weakSelf = self;
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.placeHolderImages[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.placeHolderImages count];
    };
    
    
}
@end
