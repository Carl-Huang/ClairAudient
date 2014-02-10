//
//  AutoCompletedOperation.h
//  ClairAudient
//
//  Created by vedon on 9/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AutoCompleteOperationDelegate <NSObject>
- (void)autoCompleteItems:(NSArray *)autocompletions;
@end
@interface AutoCompletedOperation : NSOperation


@property (strong ,nonatomic) NSString  *incompleteString;
@property (strong ,nonatomic) NSArray   *possibleCompletions;
@property (assign ,nonatomic) id <AutoCompleteOperationDelegate> delegate;
@property (strong ,nonatomic) NSDictionary *boldTextAttributes;
@property (strong ,nonatomic) NSDictionary *regularTextAttributes;


- (id)initWithDelegate:(id<AutoCompleteOperationDelegate>)aDelegate
      incompleteString:(NSString *)string
   possibleCompletions:(NSArray *)possibleStrings;

- (NSArray *)autocompleteSuggestionsForString:(NSString *)inputString
                          withPossibleStrings:(NSArray *)possibleTerms;
@end
