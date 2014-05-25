//
//  SoundMakerView.h
//  ClairAudient
//
//  Created by vedon on 25/5/14.
//  Copyright (c) 2014 helloworld. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SoundMakerView : UIView

@property (weak, nonatomic) IBOutlet UISlider *tempoSlider;
@property (weak, nonatomic) IBOutlet UISlider *pitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *rateSlider;

@property (strong ,nonatomic) NSString * audioFilePath;

- (IBAction)listenBtnAciont:(id)sender;
- (IBAction)sureBtnAction:(id)sender;

- (IBAction)rateSliderAction:(id)sender;
- (IBAction)pitchSliderAction:(id)sender;
- (IBAction)tempoSliderAction:(id)sender;

@end
