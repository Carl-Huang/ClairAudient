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
               placeHolderImage:(UIImageView *)image
                 placeHolderNum:(NSInteger)numOfPlaceHoderImages
   replaceWithNetworkImagesLink:(NSArray *)networkImages
                          addTo:(UIView *)parentView;
@end
