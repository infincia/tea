//
//  TimerViewController.h
//  Tea
//
//  Created by steve on 10/25/14.
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import UIKit;

@protocol TeaTimerDelegate <NSObject>
@required
-(void)teaTimerDidFinish:(id)sender;
@end

@interface TimerViewController : UIViewController
@property id<TeaTimerDelegate> delegate;
@property NSNumber *teaCountdownMinutes;
-(void)startCountdown;
@end
