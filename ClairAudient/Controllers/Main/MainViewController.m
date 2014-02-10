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
@interface MainViewController ()
@property (strong ,nonatomic)CycleScrollView * advertisementImageView;
@end

@implementation MainViewController
@synthesize advertisementImageView;
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
    
    [self testAPI];
    
    [self showAdvertisementImage];
    
    CGRect rect = self.adScrollView.frame;
    rect.origin.x = rect.origin.y = 0;
    advertisementImageView = [[CycleScrollView alloc]initWithFrame:rect cycleDirection:CycleDirectionLandscape pictures:@[] autoScroll:YES];
    [advertisementImageView setHidden:YES];
    [self.adScrollView addSubview:advertisementImageView];
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
    [ControlCenter showLoginVC];
}

- (IBAction)showSettingVC:(id)sender
{
    [ControlCenter showSettingVC];
}

#pragma mark - Private Methods
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
        for (NSString * imgStr in object) {
            //获取图片
            [[HttpService sharedInstance]getImageWithResourcePath:imgStr completedBlock:^(id object) {
                if (object) {
                    [imgArray addObject:object];
                    @synchronized(self)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.advertisementImageView setHidden:NO];
                            [weakSelf.advertisementImageView updateImageArrayWithImageArray:imgArray];
                            [weakSelf.advertisementImageView refreshScrollView];
                        });
                        
                    }
                }
            } failureBlock:^(NSError * error) {
                ;
            }];
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
   
   
    
}
@end
