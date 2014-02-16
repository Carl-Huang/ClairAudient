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
        rect = frame;
        scrollFrame = frame;
        scrollDirection = direction;
        
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
        
        totalPage = 0;
        if(pictureArray != nil)
        {
            totalPage = pictureArray.count;
        }
        if (totalPage == 1) {
            scrollView.scrollEnabled = NO;
        }
        int pageControlWidth = totalPage * 20;
        int pageControlHeight = 30;
        pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((frame.size.width-pageControlWidth)/2, frame.size.height - pageControlHeight, pageControlWidth , pageControlHeight)];
        pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        pageControl.numberOfPages = totalPage;
        pageControl.currentPage = 0;
        currentPage = 0;
        [pageControl addTarget:self action:@selector(turnPage) forControlEvents:UIControlEventValueChanged];
        
        // 定时器 循环
        isAutoScroll = shouldScroll;
        if (shouldScroll) {
            [self startTimer];
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
        
        
        if (totalPage != 0) {
            [self refreshScrollView];
        }
    }
    
    return self;
}

-(void)startTimer
{
    [self stopTimer];
    NSLog(@"timer is valid");
    timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(runTimePage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer
                                 forMode:NSRunLoopCommonModes];
}

-(void)stopTimer
{
    
    if (timer&&[timer isValid]) {
        NSLog(@"timer is invalidate");
        [timer invalidate];
        timer = nil;
    }
}

- (void)refreshScrollView {
    NSArray *subViews = [scrollView subviews];
    if([subViews count] != 0) {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    [self getDisplayImagesWithCurpage:curPage];
    if ([curImages count]) {
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
    
}

- (void)getDisplayImagesWithCurpage:(int)page {
    @try {
        int pre     = [self validPageValue:curPage-1];
        int last    = [self validPageValue:curPage+1];
        //    NSLog(@"current page :%d",curPage);
        //    NSLog(@"pre :%d",pre);
        //    NSLog(@"last :%d",last);
        //    NSLog(@"totalPage :%d",totalPage);
        if([curImages count] != 0) [curImages removeAllObjects];
        
        if ([imagesArray count]) {
            [curImages addObject:[imagesArray objectAtIndex:pre-1]];
            [curImages addObject:[imagesArray objectAtIndex:curPage-1]];
            [curImages addObject:[imagesArray objectAtIndex:last-1]];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@",exception.description);
    }
    @finally {
        ;
    }
    
}

- (int)validPageValue:(NSInteger)value {
    
    if(value == 0) value = totalPage;
    if(value == totalPage + 1) value = 1;
    
    return value;
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    @autoreleasepool {
        int x = aScrollView.contentOffset.x;
        int y = aScrollView.contentOffset.y;
        //    NSLog(@"did  x=%d  y=%d", x, y);
        
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
}

- (void)updateImageArrayWithImageArray:(NSArray *)images
{
    NSLog(@"%s",__func__);
    self.imageArrayInfo = images;
    [self stopTimer];
    
    if ([images count]) {
        @try {
            if (self.contentIdentifier) {
                @synchronized(self)
                {
                    [imagesArray removeAllObjects];
                    for (NSDictionary * dic in images) {
                        UIImage * tempImage =[dic valueForKey:self.contentIdentifier];
                        if (tempImage) {
                            [imagesArray addObject:tempImage];
                        }
                    }
                    totalPage = [imagesArray count];
                    if (totalPage == 1) {
                        scrollView.scrollEnabled = NO;
                    }
                    pageControl.numberOfPages = totalPage;
                    curPage = 1;
                }
                
            }

        }
        @catch (NSException *exception) {
            NSLog(@"error");
        }
        @finally {
            ;
        }
        [self startTimer];
    }
}

- (void)setIdentifier:(NSString *)iden andContentIdenifier:(NSString *)contentIden
{
    self.identifier         = iden;
    self.contentIdentifier  = contentIden;
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
    
    //    int x = aScrollView.contentOffset.x;
    //    int y = aScrollView.contentOffset.y;
    //    NSLog(@"--end  x=%d  y=%d", x, y);
    
    if (scrollDirection == CycleDirectionLandscape) {
        [scrollView setContentOffset:CGPointMake(scrollFrame.size.width, 0) animated:YES];
    }
    if (scrollDirection == CycleDirectionPortait) {
        [scrollView setContentOffset:CGPointMake(0, scrollFrame.size.height) animated:YES];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([delegate respondsToSelector:@selector(cycleScrollViewDelegate:didSelectImageView:)]) {
        NSInteger itemNum = curPage;
        if (itemNum >= [self.imageArrayInfo count]) {
            itemNum = self.imageArrayInfo.count -1;
        }
        NSString * tempIdentifier = nil;
        if (self.identifier) {
            tempIdentifier = [[self.imageArrayInfo objectAtIndex:itemNum]valueForKey:self.identifier];
            [delegate cycleScrollViewDelegate:self didSelectImageView:tempIdentifier];
        }
        
    }
}


- (void)turnPage
{
    pageControl.currentPage = currentPage;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self autoScroll];
    });
    
}

- (void)runTimePage
{
    if ([timer isValid]) {
        if (totalPage!=0) {
            currentPage++;
            currentPage = currentPage > totalPage-1 ? 0 : currentPage ;
            if (isAutoScroll) {
                [self turnPage];
            }
        }
    }
}
@end
