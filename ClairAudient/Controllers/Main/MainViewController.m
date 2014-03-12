//
//  MainViewController.m
//  ClairAudient
//
//  Created by vedon on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import "MainViewController.h"
#import "CustomiseImageObj.h"
#import "SDWebImageManager.h"
#import "UserDefaultMacro.h"
#import "CycleScrollView.h"
#import "ControlCenter.h"
#import "HttpService.h"
#import "AsynCycleView.h"
#import "User.h"

#import "CommentView.h"

@interface MainViewController ()
{
    BOOL isDownloadImage;
    UIImageView * placeHolderImage;
    AVAudioPlayer * player;
    
}
@property (strong ,nonatomic)AsynCycleView * autoScrollView;
@property (strong ,nonatomic)NSMutableArray * customiseImages;
@end

@implementation MainViewController
@synthesize autoScrollView,customiseImages;

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
    [self loadStartImage];
    
    customiseImages    = [NSMutableArray array];
    [self getAdvertisementImage];
    [self downloadCustomiseImage];
    
    CGRect rect = self.adScrollView.bounds;
    //Placehoder Image
    placeHolderImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"first_2.png"]];
    [placeHolderImage setFrame:rect];

    autoScrollView =  [[AsynCycleView alloc]initAsynCycleViewWithFrame:rect placeHolderImage:[UIImage imageNamed:@"first_2.png"] placeHolderNum:3 addTo:self.adScrollView];
    [autoScrollView initializationInterface];
    
    isDownloadImage = NO;
    int randNum = rand() % 6;
    if (randNum == 0) {
        randNum =1;
    }
    NSString * fileName = [NSString stringWithFormat:@"def%d",randNum];
    NSURL * fileURL = [NSURL fileURLWithPath: [[NSBundle mainBundle] pathForResource:fileName ofType:@"mp3"]];
    player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
    [player play];
    
    [self.view bringSubviewToFront:_startPageContainer];
    
    
//    [[HttpService sharedInstance]getCommentWithParams:@{@"vlId":@"378"} completionBlock:^(id object) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([object count]) {
//                CommentView * commentView = [[[NSBundle mainBundle]loadNibNamed:@"CommentView" owner:self options:nil]objectAtIndex:0];
//                [commentView configureBubbleView:object];
//                [self.view addSubview:commentView];
//            }
//        });
//    } failureBlock:^(NSError *error, NSString *responseString) {
//        ;
//    }];
    
    
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
    User * userInfo = [User userFromLocal];
    if (userInfo ) {
        IntegralViewController * viewController = [[IntegralViewController alloc]initWithNibName:@"IntegralViewController" bundle:nil];
        [viewController setUserInfo:userInfo];
        [self.navigationController pushViewController:viewController animated:YES];
        viewController = nil;

    }else
    {
        [self showAlertViewWithMessage:@"请先登陆"];
    }
    
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

- (IBAction)hideStartPageAction:(id)sender {
    [player pause];
    player = nil;
    [_startPageContainer setHidden:YES];
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

-(void)getAdvertisementImage
{
    __weak MainViewController * weakSelf = self;
    [[HttpService sharedInstance]getAdvertisementImageWithCompletedBlock:^(id object) {
        if ([object count]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [autoScrollView updateNetworkImagesLink:object];
            });
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];

}

-(void)downloadCustomiseImage
{
    __weak MainViewController * weakSelf = self;
    [[HttpService sharedInstance]getCustomiseImageWithCompletedBlock:^(id object) {
        if ([object count]) {
            for (CustomiseImageObj * obj in object) {
                NSString * str =[NSString stringWithFormat:@"%@%@",URL_PREFIX,obj.common_image];
                str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [[SDWebImageManager sharedManager]downloadWithURL:[NSURL URLWithString:str] options:SDWebImageCacheMemoryOnly progress:^(NSUInteger receivedSize, long long expectedSize) {
                    ;
                } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
                    [weakSelf.customiseImages addObject:@{@"image_type": obj.image_type,@"common_image":image}];
                    [weakSelf updateInterface];
                }];
            }
            
        }
    } failureBlock:^(NSError *error, NSString *responseString) {
        ;
    }];
}

-(void)updateInterface
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSDictionary * dic in customiseImages) {
            if ([dic[@"image_type"]isEqualToString:@"积分图片"]) {
                [_jifenBtn setBackgroundImage:dic[@"common_image"] forState:UIControlStateNormal];
            }else if([dic[@"image_type"]isEqualToString:@"寻音图片"])
            {
                [_xunyinBtn setBackgroundImage:dic[@"common_image"] forState:UIControlStateNormal];
            }else if([dic[@"image_type"]isEqualToString:@"欢迎图片"])
            {
                //save the startImage to local
                UIImage * image = dic[@"common_image"];
                
                
                [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(image) forKey:StartImage];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
            
        }
    });
}

-(void)loadStartImage
{
    NSData* imageData = [[NSUserDefaults standardUserDefaults]objectForKey:StartImage];
    UIImage* image = [UIImage imageWithData:imageData];
    if (image) {
        _startImage.image = image;
        image = nil;
    }

}
@end
