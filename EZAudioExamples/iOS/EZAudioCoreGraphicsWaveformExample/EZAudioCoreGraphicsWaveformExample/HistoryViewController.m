//
//  HistoryViewController.m
//  noise
//
//  Created by Edward Sykes on 05/11/2014.
//  Copyright (c) 2014 Syed Haris Ali. All rights reserved.
//

#import "NoiseModel.h"
#import "HistoryViewController.h"
#import "AppDelegate.h"

@interface HistoryViewController (){
    NSMutableArray* fullHistory;
}

@property NoiseModel* noiseModel;
@property HelpModel* helpModel;
@property bool animating;
@property (weak, nonatomic) IBOutlet UIImageView *outerTicker;
@property (weak, nonatomic) IBOutlet UIImageView *middleTicker;
@property (weak, nonatomic) IBOutlet UIImageView *innerTicker;

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _helpModel = [HelpModel new];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _noiseModel = appDelegate.noiseModel;
    _noiseModel.noiseView = self;
    fullHistory = [_noiseModel fullHistory];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [fullHistory count];
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyIdentifier"];
    
    /*
     *   If the cell is nil it means no cell was available for reuse and that we should
     *   create a new one.
     */
    if (cell == nil) {
        
        /*
         *   Actually create a new cell (with an identifier so that it can be dequeued).
         */
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"MyIdentifier"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    /*
     *   Now that we have a cell we can configure it to display the data corresponding to
     *   this row/section
     */
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    NSString* str = fullHistory[indexPath.row][@"dateTime" ];
    NSDate* date = [df dateFromString:str];
    
    NSTimeZone *outputTimeZone = [NSTimeZone localTimeZone];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setTimeZone:outputTimeZone];
    [outputDateFormatter setDateStyle:NSDateFormatterShortStyle];
    [outputDateFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *outputString = [outputDateFormatter stringFromDate:date];
    
    cell.textLabel.text = [NSString stringWithFormat: @"%@: %@ decibels", outputString, fullHistory[indexPath.row][@"properties"][@"dbspl"]];
//    cell.detailTextLabel.text = [NSString stringWithFormat: @"lat: %@ long: %@", fullHistory[indexPath.row][@"location"][@"lat"], fullHistory[indexPath.row][@"location"][@"long"]];
    cell.textLabel.textColor =  [UIColor colorWithRed:256/256.0 green:256/256.0 blue:256/256.0 alpha:0.9];
    cell.detailTextLabel.textColor =  [UIColor colorWithRed:256/256.0 green:256/256.0 blue:256/256.0 alpha:0.6];
    cell.backgroundColor = [UIColor colorWithRed:0/256.0 green:0/256.0 blue:0/256.0 alpha:0.4];
    
    /* Now that the cell is configured we return it to the table view so that it can display it */
    
    return cell;
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
    self.tableView.backgroundColor = [UIColor colorWithRed:redness green:greenness blue:0.4 alpha:1];
    self.audioPlot.backgroundColor = [UIColor colorWithRed:redness green:greenness blue:0.4 alpha:1];
}

- (void)UpdateUIStats
{
    self.lblDbspl.text = [NSString stringWithFormat: @"%@", _noiseModel.dbspl];
    self.autoupload.text = _noiseModel.autouploadLeft;
}

- (void)updateView{
    [self UpdateUIStats];
    [self UpdateViewBackground];
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

- (IBAction)TapperDial:(id)sender {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"MainView"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:nil];
}
@end
