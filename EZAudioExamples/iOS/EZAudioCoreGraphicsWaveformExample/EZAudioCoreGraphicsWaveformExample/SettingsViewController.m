//
//  SettingsViewController.m
//  noise
//
//  Created by Edward Sykes on 21/10/2014.
//  Copyright (c) 2014 Syed Haris Ali. All rights reserved.
//
#import "NoiseModel.h"
#import "SettingsViewController.h"
#import "AppDelegate.h"
#import "UIAlertView+additions.h"

@interface SettingsViewController ()
@property NoiseModel* noiseModel;
@property BeaconModel* beaconModel;
@property HelpModel* helpModel;
@property bool animating;
@property (weak, nonatomic) IBOutlet UIImageView *outerTicker;
@property (weak, nonatomic) IBOutlet UIImageView *middleTicker;
@property (weak, nonatomic) IBOutlet UIImageView *innerTicker;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _helpModel = [HelpModel new];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _noiseModel = appDelegate.noiseModel;
    _noiseModel.noiseView = self;
    _connected.on = _noiseModel.connected;
    _beaconModel = appDelegate.beaconModel;
    _beaconEnabled.on = _beaconModel.enabled;
}

- (void)viewDidAppear:(BOOL)animated {
    [self animate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)load{
}

- (void)animate
{
    [self animateInner];
    [self animateMiddle];
    [self animateOuter];
}

- (void)UpdateViewBackground
{
    float redness = _noiseModel.fdbspl / 100;
    float greenness = 1 - redness;
    self.view.backgroundColor = [UIColor colorWithRed:redness green:greenness blue:0.4 alpha:1];
    self.audioPlot.backgroundColor = [UIColor colorWithRed:redness green:greenness blue:0.4 alpha:1];
}

- (void)UpdateUIStats
{
    self.lblDbspl.text = [NSString stringWithFormat: @"%@", _noiseModel.dbspl];
    self.autoupload.text = _noiseModel.autouploadLeft;
}

-(void)UpdateHelp{
    _helpText.text = _helpModel.helpText;
}

- (void)updateView{
    [self UpdateUIStats];
    [self UpdateViewBackground];
    [self UpdateHelp];
}

-(void)updateAudioPlots:(float *)buffer
         withBufferSize:(UInt32)bufferSize{
    [self.audioPlot updateBuffer:buffer withBufferSize:bufferSize];
    
}

- (void) animateInner
{
    float rotations = 1.0;
    int duration = 1;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0 * 60 * 60;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    
    [_innerTicker.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) animateMiddle
{
    float rotations = 1.0 / 60;
    int duration = 1;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0 * 60 * 60;
    
    
    [_middleTicker.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

- (void) animateOuter
{
    float rotations = 1.0 / 60 / 20;
    int duration = 1;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 1.0 * 60 * 60;
    
    
    [_outerTicker.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)goToBackground{
    
}

-(void)goToForeground{
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)tapDial:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)requestConnect: (void (^) (NSUInteger index)) connectBlock
{
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"1self Noise data policy"
    //                                                    message:@"1self Noise uses the 1self cloud to show you smart visualizations of your noise. Once connected you can also share and correlate your data. We use connected data to build a high level public map of our noisy planet. Your raw data will never be shown and it won't be possible to tell who you are or where you've been. Would you like to connect Noise to the 1self cloud?"
    //                                                    buttons:@[ @"No", @"Connect" ]
    //                                              buttonHandler:connectBlock
    [UIAlertView presentWithTitle:@"1self Noise data policy"
                          message:@"This will send your noise level anonymously to 1self servers at 1self.co. We do this to give you visualizations of your data. We never share this data. You may explicitly choose to share it using the share feature on 1self.\n\nMore information on our privacy policy can be found at http://www.1self.co/privacy.html"
                          buttons:@[ @"No", @"Send data" ]
                    buttonHandler:connectBlock];
}

- (IBAction)clickConnected:(id)sender {
    if(_connected.on)
    {
        [self requestConnect: ^(NSUInteger buttonIndex){
            if (buttonIndex == 1) {
                [_noiseModel connect];
            }
            else{
                _connected.on = false;
            }
        }];
    }
    else
    {
        [_noiseModel disconnect];
    }
}

- (IBAction)clickPublic:(UISwitch*)sender {
    if(sender.on){
        [_beaconModel startAdvertisingBeacon];
    }
    else
    {
        [_beaconModel stopAdvertisingBeacon];
    }

}
@end
