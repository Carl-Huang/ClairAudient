//
//  AppDelegate.h
//  ClairAudient
//
//  Created by Carl on 13-12-30.
//  Copyright (c) 2013年 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AFURLConnectionOperation;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController * navigationController;

@property (strong, nonatomic) NSOperationQueue * downloadOperateQueue;

-(void)addnewOperation:(NSOperation *)operation;
@end
