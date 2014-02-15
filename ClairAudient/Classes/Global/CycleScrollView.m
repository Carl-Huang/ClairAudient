//
//  CycleScrollView
//  AStore
//
//  Created by vedon on 5/11/13.
//  Copyright (c) 2013 carl. All rights reserved.
//

#import "CycleScrollView.h"

@implementation CycleScrollView
@synthesize delegate;
@synthesize pageControl;
@synthesize timer;
@synthesize imagesArray;

#pragma mark - Public Method
- (id)initWithFrame:(CGRect)frame cycleDirection:(CycleDirection)direction pictures:(NSArray *)pictureArray autoScroll:(BOOL)shouldScroll
{
    self = [super initWithFrame:frame];
    if(self)
    {
        shouldAutoScroll = shouldScroll;
        rect = frame;
        scrollFrame = frame;
        scrollDirection = direction;
        totalPage = pictureArray.count;
        curPage = 1;  
        curImages = [[NSMutableArray alloc] init];
        imagesArray = [NSMutableArray arrayWithArray:pictureArray];
        
        scrollView = [[UIScrollView alloc] initWithFrame:frame];
        scrollView.backgroundColor = [UIColor blackColor];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        [self addSubview:scrollView];
        
        viewCount = 0;
        if(pictureArray != nil)
        {
            viewCount = [pictureArray count];
        }
        int pageControlWidth = viewCount * 20;
        int pageControlHeight = 30;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((frame.size.width-pageControlWidth)/2, frame.size.height - pageControlHeight, pageControlWidth , pageControlHeight)];
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        pageControl.numberOfPages = viewCount;
        pageControl.currentPage = 0;
        currentPage = 0;
        [pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
        
        // 定时器 循环
        if (shouldAutoScroll) {
            timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer
                                         forMode:NSRunLoopCommonModes];
        }
        [self addSubview:pageControl];
        
        // 在水平方向滚动
        if(scrollDirection == CycleDirectionLandscape) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3,
                                                scrollView.frame.size.height);
        }
        // 在垂直方向滚动 
        if(scrollDirection == CycleDirectionPortait) {
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width,
                                                scrollView.frame.size.height * 3);
        }
        isAutoScroll = YES;

        if (viewCount != 0) {
            [self refreshScrollView];
        }
    }
    
    return self;
}

- (void)refreshScrollView {
    
    NSArray *subViews = [scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:curPage];
    
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:scrollFrame];
        imageView.userInteractionEnabled = YES;
        imageView.image = [curImages objectAtIndex:i];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [imageView addGestureRecognizer:singleTap];
        singleTap  = nil;
        // 水平滚动
        if(scrollDirection == CycleDirectionLandscape) {
            imageView.frame = CGRectOffset(imageView.frame, scrollFrame.size.width * i, 0);
        }
        // 垂直滚动
        if(scrollDirection == CycleDirectionPortait) {
            imageView.frame = CGRectOffset(imageView.frame, 0, scrollFrame.size.height * i);
        }
        
        
        [scrollView addSubview:imageView];
    }
    if (scrollDirection == CycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0)];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height)];
    }
}

- (NSArray *)getDisplayImagesWithCurpage:(int)page {
    
    int pre = [self validPageValue:curPage-1];
    int last = [self validPageValue:curPage+1];
    
    if([curImages count] != 0) [curImages removeAllObjects];
    
    if ([imagesArray count]) {
        [curImages addObject:[imagesArray objectAtIndex:pre-1]];
        [curImages addObject:[imagesArray objectAtIndex:curPage-1]];
        [curImages addObject:[imagesArray objectAtIndex:last-1]];
    }
    return curImages;
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == 0) value = totalPage;                   // value＝1为第一张，value = 0为前面一张
    if(value == totalPage + 1) value = 1;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    NSLog(@"did  x=%d  y=%d", x, y);

    if(scrollDirection == CycleDirectionLandscape) {
        // 往下翻一张
        if(x >= (2*scrollFrame.size.width-20)) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(x <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    // 垂直滚动
    if(scrollDirection == CycleDirectionPortait) {
        // 往下翻一张
        if(y >= 2 * (scrollFrame.size.height)) { 
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
        if(y <= 0) {
            curPage = [self validPageValue:curPage-1];
            [self refreshScrollView];
        }
    }
    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
        [delegate cycleScrollViewDelegate:self didScrollImageView:curPage];
    }
}

- (void)updateImageArrayWithImageArray:(NSArray *)images
{
    if ([images count]) {
        [imagesArray removeAllObjects];
        for (UIImage * image in images) {
            if (image) {
                [imagesArray addObject:image];
            }
        }
        totalPage = [images count];
        viewCount = totalPage;
    }
}

#pragma mark - Private Method
-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    isAutoScroll = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
            isAutoScroll = NO;
}
-(void)autoScroll
{
   
    if(scrollDirection == CycleDirectionLandscape) {
        // 往下翻一张
        if(isAutoScroll) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
           }
    
    // 垂直滚动
    if(scrollDirection == CycleDirectionPortait) {
        // 往下翻一张
        if(isAutoScroll) {
            curPage = [self validPageValue:curPage+1];
            [self refreshScrollView];
        }
    }
    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didScrollImageView:)]) {
        [delegate cycleScrollViewDelegate:self didScrollImageView:curPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView {
    
    int x = aScrollView.contentOffset.x;
    int y = aScrollView.contentOffset.y;
    
    NSLog(@"--end  x=%d  y=%d", x, y);
    
    if (scrollDirection == CycleDirectionLandscape) {
            [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didSelectImageView:)]) {
        [delegate cycleScrollViewDelegate:self didSelectImageView:curPage];
    }
}


- (void)turnPage
{
    NSLog(@"%d",currentPage);
    pageControl.currentPage = currentPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self autoScroll];
    });
    
}

- (void)runTimePage
{
    if (viewCount!=0) {
        currentPage++;
        currentPage = currentPage > viewCount-1 ? 0 : currentPage ;
        if (isAutoScroll) {
            [self turnPage];
        }
    }
}
@end
