//
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import QuartzCore;

#import "TimerViewController.h"
#import "SteepController.h"

@interface TimerViewController ()

@property SteepController *sharedSteepController;

@property IBOutlet UIButton *mainButton;
@property IBOutlet UILabel *timerLabel;
@property IBOutlet UIProgressView *progressBar;

@end

@implementation TimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sharedSteepController = [SteepController sharedSteepController];
}

-(void)dealloc {
    self.sharedSteepController.timerDelegate = nil;
    [self.sharedSteepController cancelSteepTimer];
}

-(void)viewWillAppear:(BOOL)animated {
    [self.mainButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.mainButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}



-(IBAction)dismiss:(id)sender {
    [self.sharedSteepController cancelSteepTimer];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
        //
    }];
}

#pragma mark
#pragma mark SteepTimerDelegate actions

-(void)displayAlert:(NSString *)title withMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //
    }];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:^{
        //
    }];
}

-(void)steepTimeRemaining:(NSTimeInterval)timeRemaining outOfSteepTime:(NSTimeInterval)initialTime {
    float div = (float)timeRemaining/(float)initialTime;

    NSInteger timeLeft = timeRemaining;
    NSInteger seconds = timeLeft % 60;
    NSInteger minutes = (timeLeft / 60) % 60;
    NSString *countdown = [NSString stringWithFormat:@"%02li:%02li", (long)minutes, (long)seconds];

    [self.progressBar setProgress:div animated:YES];

    self.timerLabel.hidden = NO;
    self.timerLabel.text = countdown;


    if (timeRemaining < 10) {

        CABasicAnimation *theAnimation;

        theAnimation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
        theAnimation.duration=0.3;
        theAnimation.repeatCount=1;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:1.2];
        [self.timerLabel.layer addAnimation:theAnimation forKey:@"animateScale"];
    }
    if (timeRemaining == 9) {
        self.timerLabel.textColor = [UIColor redColor];
        self.progressBar.progressTintColor = [UIColor redColor];
    }
}

@end
