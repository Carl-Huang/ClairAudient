//
//  MainViewController.m
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import "MainViewController.h"
#import "ControlCenter.h"
#import "HttpService.h"
#import "CycleScrollView.h"
#import "User.h"

@interface MainViewController ()
{

}
@property (strong ,nonatomic)CycleScrollView * autoScrollView;
@property (strong ,nonatomic)NSMutableArray * productImages;
@end

@implementation MainViewController
@synthesize autoScrollView,productImages;

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.navigationController setNavigationBarHidden:YES];
    
//    [self testAPI];
    
    [self showAdvertisementImage];
    
    CGRect rect = self.adScrollView.frame;
    rect.origin.x = rect.origin.y = 0;
    autoScrollView = [[CycleScrollView alloc] initWithFrame:rect animationDuration:2];
    autoScrollView.backgroundColor = [UIColor clearColor];
    
    NSMutableArray * images = [NSMutableArray array];
    //Placehoder Image
    if ([productImages count] == 0) {
        productImages = [NSMutableArray arrayWithArray: @[[UIImage imageNamed:@"first_2.png"]]];
    }
    for (UIImage * image in productImages) {
        UIImageView * tempImageView = [[UIImageView alloc]initWithImage:image];
        [tempImageView setFrame:rect];
        [images addObject:tempImageView];
        tempImageView = nil;
    }
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return images[pageIndex];
    };
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [images count];
    };
    autoScrollView.TapActionBlock = ^(NSInteger pageIndex){
        NSLog(@"点击了第%ld个",(long)pageIndex);
    };
    [self.adScrollView addSubview:autoScrollView];
    [self.view bringSubviewToFront:self.adScrollView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UIButton Actions
- (IBAction)showRecordVC:(id)sender
{
    
    [ControlCenter showRecordVC];
}

- (IBAction)showFoundMusicVC:(id)sender
{
    [ControlCenter showFIndSoundVC];
}

- (IBAction)showMixingMusicVC:(id)sender
{
    [ControlCenter showMixingMusicListVC];
}

- (IBAction)showMusicFansVC:(id)sender
{
    [ControlCenter showMusicFansVC];
}

- (IBAction)showIntegralVC:(id)sender
{
    [ControlCenter showIntegralVC];
}

- (IBAction)showAccountVC:(id)sender
{
    User * user = [User userFromLocal];
    if (user == nil) {
        [ControlCenter showLoginVC];
    }else
    {
        [ControlCenter showUserCenterVC];
    }
}

- (IBAction)showSettingVC:(id)sender
{
    [ControlCenter showSettingVC];
}

#pragma mark - Private Methods
-(void)updateAutoScrollViewItem
{
    __weak MainViewController * weakSelf = self;
    autoScrollView.totalPagesCount = ^NSInteger(void){
        return [weakSelf.productImages count];
    };
    autoScrollView.fetchContentViewAtIndex = ^UIView *(NSInteger pageIndex){
        return weakSelf.productImages[pageIndex];
    };
   
}

- (void)testAPI
{
    [[HttpService sharedInstance] findCatalog:@{@"parentId":@"0"} completionBlock:^(id obj) {
        NSLog(@"findCatalog");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findVoiceByCatalog:@{@"vltId":@"13",@"pageSize":@"10",@"index":@"1"} completionBlock:^(id object) {
        NSLog(@"findVoiceByCatalog");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findCommentByVoice:@{@"vlId":@"1450"} completionBlock:^(id object) {
        NSLog(@"findCommentByVoice");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findMyUploadByUser:@{@"userId":@"8"} completionBlock:^(id object) {
        NSLog(@"findMyUploadByUser");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findIntegralRankUserWithCompletionBlock:^(id object) {
        NSLog(@"findIntegralRankUser");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    
    [[HttpService sharedInstance] findRecommendByCatalog:@{@"parentId":@"2"} completionBlock:^(id object) {
        NSLog(@"findRecommendByCatalog");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findCatalogRankVoice:@{@"parentId":@"2"} completionBlock:^(id object) {
        NSLog(@"findCatalogRankVoice");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
    
    [[HttpService sharedInstance] findDownloadRankVoiceWithCompletionBlock:^(id object) {
        NSLog(@"findDownloadRankVoice");
    } failureBlock:^(NSError *error, NSString *responseString) {
        
    }];
}

-(void)showAdvertisementImage
{
    __weak MainViewController * weakSelf = self;
    __block NSMutableArray * imgArray = [NSMutableArray array];
    [[HttpService sharedInstance]getAdvertisementImageWithCompletedBlock:^(id object) {
        if ([object count]) {
            for (NSString * imgStr in object) {
                //获取图片
                [weakSelf getImage:imgStr withContainer:imgArray];
            }
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)getImage:(NSString *)imgStr withContainer:(NSMutableArray *)container
{
    __weak MainViewController * weakSelf = self;

    [[HttpService sharedInstance]getImageWithResourcePath:imgStr completedBlock:^(id object) {
        if (object) {
            NSDictionary * tempDic = @{@"identifier": imgStr,@"Image":object};
            UIImageView * imageView = nil;
            [weakSelf.productImages addObject:tempDic];
            if ([object isKindOfClass:[UIImage class]]) {
                imageView = [[UIImageView alloc]initWithImage:object];
                [productImages addObject:imageView];
            }
        }
    } failureBlock:^(NSError * error) {
        ;
    }];
}
@end
