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
    
    int viewCount;
    CGRect rect;
    BOOL shouldAutoScroll;
    NSInteger currentPage;
    BOOL isAutoScroll;
    
   
}

@property (nonatomic, weak) id<CycleScrollViewDelegate> delegate;
@property (nonatomic, strong) UIPageControl    *pageControl;
@property (strong, nonatomic) NSTimer          *timer;
@property (strong, nonatomic) NSMutableArray   *imagesArray;               // 存放所有需要滚动的图片 UIImage
//@property (assign ,nonatomic) CGRect            pageControllerRect;

- (int)validPageValue:(NSInteger)value;
- (id)initWithFrame:(CGRect)frame
     cycleDirection:(CycleDirection)direction
           pictures:(NSArray *)pictureArray
         autoScroll:(BOOL)shouldScroll;

- (NSArray *)getDisplayImagesWithCurpage:(int)page;
- (void)refreshScrollView;
- (void)updateImageArrayWithImageArray:(NSArray *)images;


@end

@protocol CycleScrollViewDelegate <NSObject>
@optional
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didSelectImageView:(int)index;
- (void)cycleScrollViewDelegate:(CycleScrollView *)cycleScrollView didScrollImageView:(int)index;

@end