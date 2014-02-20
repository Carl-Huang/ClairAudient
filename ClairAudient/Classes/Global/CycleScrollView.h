//
//  CycleScrollView
//  AStore
//
//  Created by vedon on 5/11/13.
//  Copyright (c) 2013 carl. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef enum {
    CycleDirectionPortait,          // 垂直滚动
    CycleDirectionLandscape         // 水平滚动
}CycleDirection;

@protocol CycleScrollViewDelegate;

@interface CycleScrollView : UIView <UIScrollViewDelegate> {
    
    UIScrollView *scrollView;
    UIImageView *curImageView;
    
    int totalPage;
    int curPage;
    CGRect scrollFrame;
    
    CycleDirection scrollDirection;     // scrollView滚动的方向
    NSMutableArray *curImages;          // 存放当前滚动的三张图片
    
    CGRect rect;
    NSInteger currentPage;
    BOOL isAutoScroll;
    
    NSInteger timerDuration;
}

@property (nonatomic, weak) id<CycleScrollViewDelegate> delegate;
@property (nonatomic, strong) UIPageControl    *pageControl;
@property (strong, nonatomic) NSTimer          *timer;
@property (strong, nonatomic) NSMutableArray   *imagesArray;               // 存放所有需要滚动的图片 UIImage
@property (strong, nonatomic) NSArray          *imageArrayInfo;
@property (strong, nonatomic) NSString         * identifier;
@property (strong, nonatomic) NSString         * contentIdentifier;
- (int)validPageValue:(NSInteger)value;
- (id)initWithFrame:(CGRect)frame
     cycleDirection:(CycleDirection)direction
           pictures:(NSArray *)pictureArray
         autoScroll:(BOOL)shouldScroll;

- (void)refreshScrollView;
- (void)updateImageArrayWithImageArray:(NSArray *)images;

/**
 @desc 把标识符（identifier） 和需要标示的内容（contentIdentifier）传递过去。在cycleScrollViewDelegate: didSelectImageView: delegate中可以获取传递回来的identifier
 */
- (void)setIdentifier:(NSString *)iden andContentIdenifier:(NSString *)contentIden;

@end

@protocol CycleScrollViewDelegate <NSObject>
@optional
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(NSString *)index;
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index;

@end