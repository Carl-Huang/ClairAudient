//
//  ShareManager.m
//  YouLa
//
//  Created by vedon on 8/1/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "ShareManager.h"
#import <ShareSDK/ShareSDK.h>


static ShareManager * shareManager;
@implementation ShareManager

+(ShareManager *)shareManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[ShareManager alloc]init];
    });
    return shareManager;
}


-(void)shareWithType:(ShareType)type WithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{
    id<ISSContent> publishContent = [ShareSDK content:shareContent
                                       defaultContent:@""
                                                image:[ShareSDK jpegImageWithImage:shareImage quality:1]
                                                title:title
                                                  url:nil
                                          description:nil
                                            mediaType:SSPublishContentMediaTypeText];
    
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:YES
                                                     wxSessionButtonHidden:YES
                                                    wxTimelineButtonHidden:YES
                                                      showKeyboardOnAppear:YES
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(@"发表成功");
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(@"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}

- (void)shareToSinaWeiboWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{
    [self shareWithType:ShareTypeSinaWeibo WithTitle:title content:shareContent image:shareImage];
}

- (void)shareToRenRenWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{
    [self shareWithType:ShareTypeRenren WithTitle:title content:shareContent image:shareImage];
}

- (void)shareToWeiXinContentWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{
    
//    [self shareWithType:ShareTypeWeixiSession WithTitle:title content:shareContent image:shareImage];
    id<ISSContent> content = [ShareSDK content:shareContent
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:shareImage quality:1]
                                         title:title
                                           url:@""
                                   description:nil
                                     mediaType:SSPublishContentMediaTypeApp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            NSLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:@"知道了"
                                                                          otherButtonTitles:nil];
                                [alertView show];
                                alertView = nil;
                            }
                        }
                    }];
}


- (void)shareToQQSpaceWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{

    [self shareWithType:(ShareTypeQQSpace) WithTitle:title content:shareContent image:shareImage];
}

-(void)shareToTencentWeiboWithTitle:(NSString *)title content:(NSString *)shareContent image:(UIImage *)shareImage
{
    [self shareWithType:(ShareTypeTencentWeibo) WithTitle:title content:shareContent image:shareImage];

}
@end
