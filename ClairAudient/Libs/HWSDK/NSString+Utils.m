//
//  NSString+Utils.m
//  HWSDK
//
//  Created by Carl on 13-11-25.
//  Copyright (c) 2013年 HelloWorld. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)
- (NSString *)filterHTML
{
    NSScanner * theScanner;
    NSString * text = nil;
    NSString * html = self;
    theScanner = [NSScanner scannerWithString:html];
    while ([theScanner isAtEnd] == NO) {
        [theScanner scanUpToString:@"<" intoString:NULL];
        [theScanner scanUpToString:@">" intoString:&text];
        html = [html stringByReplacingOccurrencesOfString:[ NSString stringWithFormat:@"%@>", text] withString:@" "];
    }
    html = [html stringByReplacingOccurrencesOfString:@"&nbsp;" withString:@" "];
    return html;
}
@end
