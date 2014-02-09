//
//  AutoCompletedOperation.m
//  ClairAudient
//
//  Created by vedon on 9/2/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import "AutoCompletedOperation.h"
#import "NSString+Levenshtein.h"
@implementation AutoCompletedOperation

- (void)main
{
    @autoreleasepool {
        
        if (self.isCancelled){
            return;
        }
        NSArray *results = [self autocompleteSuggestionsForString:self.incompleteString
                                              withPossibleStrings:self.possibleCompletions];
        
        if (self.isCancelled){
            return;
        }
        
        if(!self.isCancelled){
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(autoCompleteItems:)
                                                        withObject:results
                                                     waitUntilDone:NO];
        }
    }
}

- (id)initWithDelegate:(id<AutoCompleteOperationDelegate>)aDelegate
      incompleteString:(NSString *)string
   possibleCompletions:(NSArray *)possibleStrings
{
    self = [super init];
    if (self) {
        [self setDelegate:aDelegate];
        [self setIncompleteString:string];
        [self setPossibleCompletions:possibleStrings];
    }
    return self;
}

- (NSArray *)autocompleteSuggestionsForString:(NSString *)inputString withPossibleStrings:(NSArray *)possibleTerms
{
    if([inputString isEqualToString:@""]){
        return [NSArray array];
    }
    
    if(self.isCancelled){
        return [NSArray array];
    }
    
    NSMutableArray *editDistances = [NSMutableArray arrayWithCapacity:possibleTerms.count];
    
    
    float editDistanceOfCurrentString;
    NSDictionary *stringsWithEditDistances;
    NSUInteger maximumRange;
    for(NSDictionary * item in possibleTerms) {
        NSString * currentString = [item valueForKey:@"Title"];
        if(self.isCancelled){
            return [NSArray array];
        }
        
        maximumRange = (inputString.length < currentString.length) ? inputString.length : currentString.length;
        editDistanceOfCurrentString = [inputString asciiLevenshteinDistanceWithString:[currentString substringWithRange:NSMakeRange(0, maximumRange)]];
        
        stringsWithEditDistances = @{@"MusicInfo" : item ,
                                     @"editDistance" : [NSNumber numberWithFloat:editDistanceOfCurrentString]};
        [editDistances addObject:stringsWithEditDistances];
    }
    
    if(self.isCancelled){
        return [NSArray array];
    }
    
    [editDistances sortUsingComparator:^(NSDictionary *string1Dictionary,
                                         NSDictionary *string2Dictionary){
        
        return [string1Dictionary[@"editDistance"] compare:string2Dictionary[@"editDistance"]];
    }];
    
    
    NSString *suggestedString = nil;
    NSMutableArray *prioritySuggestions = [NSMutableArray array];
    NSMutableArray *otherSuggestions = [NSMutableArray array];
    for(NSDictionary *stringsWithEditDistances in editDistances){
        
        if(self.isCancelled){
            return [NSArray array];
        }
        NSDictionary * tempDic = stringsWithEditDistances[@"MusicInfo"];
        suggestedString = tempDic[@"Title"];
        NSRange occurrenceOfInputString = [[suggestedString lowercaseString]
                                           rangeOfString:[inputString lowercaseString]];
        
        if (occurrenceOfInputString.length != 0 && occurrenceOfInputString.location == 0) {
            [prioritySuggestions addObject:tempDic];
        } else{
            [otherSuggestions addObject:tempDic];
        }
    }
    
    NSMutableArray *results = [NSMutableArray array];
    [results addObjectsFromArray:prioritySuggestions];
    [results addObjectsFromArray:otherSuggestions];
    
    
    return [NSArray arrayWithArray:results];
}

- (void)dealloc
{
    [self setDelegate:nil];
    [self setIncompleteString:nil];
    [self setPossibleCompletions:nil];
}

@end
