//
//  DebugController.h
//  noise
//
//  Created by Edward Sykes on 21/10/2014.
//  Copyright (c) 2014 Syed Haris Ali. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DebugController : UIViewController<NoiseView,UIPickerViewDelegate>
- (IBAction)tapBack:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *apiOptions;

@end
