//
//  TimerViewController.m
//  Tea
//
//  Created by steve on 10/25/14.
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

#import "TimerViewController.h"
@import QuartzCore;

@interface TimerViewController () {
    NSTimeInterval initialTimeSeconds;
    NSTimeInterval remainingTimeSeconds;
}
@property IBOutlet UIButton *mainButton;
@property IBOutlet UILabel *timerLabel;
@property IBOutlet UIProgressView *progressBar;
@property NSTimer *timer;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

-(void)dealloc {
    //if (self.timer.isValid) [self.timer invalidate];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.mainButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.mainButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self updateTimeDisplay];
}

-(void)startCountdown {
    initialTimeSeconds = [self.teaCountdownMinutes integerValue] * 60;
    remainingTimeSeconds = initialTimeSeconds;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self updateTimeDisplay];
}

-(IBAction)dismiss:(id)sender {
    if (self.timer.isValid) [self.timer invalidate];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}


-(void)tick {
    NSLog(@"Thread: %@", [NSThread currentThread]);
    [self updateTimeDisplay];
    if (remainingTimeSeconds > 0) {
        remainingTimeSeconds--;
    }
    else {
        [self.timer invalidate];
        [self.delegate teaTimerDidFinish:self];
    }

}

-(void)updateTimeDisplay {
    float div = (float)remainingTimeSeconds/(float)initialTimeSeconds;

    NSInteger timeLeft = (NSInteger)remainingTimeSeconds;
    NSInteger seconds = timeLeft % 60;
    NSInteger minutes = (timeLeft / 60) % 60;
    NSString *countdown = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];

    [self.progressBar setProgress:div animated:YES];
    self.timerLabel.text = countdown;


    if (remainingTimeSeconds < 10) {

        CABasicAnimation *theAnimation;

        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=0.3;
        theAnimation.repeatCount=1;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:1.2];
        [self.timerLabel.layer addAnimation:theAnimation forKey:@"animateScale"];
    }
    if (remainingTimeSeconds == 9) {
        self.timerLabel.textColor = [UIColor redColor];
        self.progressBar.progressTintColor = [UIColor redColor];
    }
    if (remainingTimeSeconds == 0) {
        [self.mainButton setTitle:@"Done" forState:UIControlStateNormal];
        [self.mainButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        /*
        CABasicAnimation *theAnimation;

        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=1.0;
        theAnimation.repeatCount=HUGE_VALF;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:1.3];
        [self.mainButton.layer addAnimation:theAnimation forKey:@"animateScale"];*/
    }
}

@end
