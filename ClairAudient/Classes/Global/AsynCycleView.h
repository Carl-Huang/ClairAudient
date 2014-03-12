//
//  AsynCycleView.h
//  ClairAudient
//
//  Created by vedon on 12/3/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynCycleView : NSObject

-(id)initAsynCycleViewWithFrame:(CGRect)rect
               placeHolderImage:(UIImage *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
                          addTo:(UIView *)parentView;
-(void)initializationInterface;
-(void)updateNetworkImagesLink:(NSArray *)links;
-(void)cleanAsynCycleView;
@end
