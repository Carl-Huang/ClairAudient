//
//  UIViewController+BarItem.h
//  HWSDK
//
//  Created by Carl_Huang on 13-11-19.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (BarItem)
#pragma mark - Instance Methods
/*
  *  @desc 设置导航栏的左边按钮
  *  @param NSString imageName 图标名称
  *  @param SEL selector 按钮的点击事件
  *  @return void
  */
- (void)setLeftCustomBarItem:(NSString *)imageName action:(SEL)selector;


/*
  *  @desc 设置导航栏的右边按钮
  *  @param NSString imageName 图标名称
  *  @param SEL selector 按钮的点击事件
  *  @return void
  */
- (void)setRightCustomBarItem:(NSString *)imageName action:(SEL)selector;


/*
 *  @desc 生成导航栏上面的按钮
 *  @param NSString imageName 图标名称
 *  @param SEL selector 按钮的点击事件
 *  @return UIBarButtonItem
 */
- (UIBarButtonItem *)customBarItem:(NSString *)imageName action:(SEL)selector;


/*
 *  @desc 生成导航栏上面的按钮
 *  @param NSString imageName 图标名称
 *  @param SEL selector 按钮的点击事件
 *  @param CGSize itemSize 按钮的大小
 *  @return UIBarButtonItem
 */
- (UIBarButtonItem *)customBarItem:(NSString *)imageName action:(SEL)selector size:(CGSize)itemSize;

/**
 @desc 返回上一个VIewController
 @return void
  */
- (void)popVIewController;
/**
 @desc 返回RootVIewController
 @return void
 */
- (void)popToRoot;
/**
 @desc 进入下一个ViewController
 @return void
 */
- (void)push:(UIViewController *)viewController;
@end
