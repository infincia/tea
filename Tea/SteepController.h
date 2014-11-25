//
//  SteepController.h
//  Tea
//
//  Created by steve on 10/25/14.
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import UIKit;
@class HKQuantityType;

typedef NS_ENUM(NSInteger, TeaType) {
    TeaTypeWhite,
    TeaTypeGreen,
    TeaTypeBlack,
    TeaTypeOolong,
    TeaTypeRooibos,
    TeaTypeHerbal
};

@protocol SteepControllerDelegate <NSObject>
@required
-(void)displayAlert:(NSString *)title withMessage:(NSString *)message;
-(void)steepDidFinish:(id)sender;
@end

@protocol SteepTimerDelegate <NSObject>
@required
-(void)displayAlert:(NSString *)title withMessage:(NSString *)message;
-(void)steepTimeRemaining:(NSTimeInterval)timeRemaining outOfSteepTime:(NSTimeInterval)initialTime;
@end

@interface SteepController : NSObject

@property (weak) id<SteepTimerDelegate> timerDelegate;
@property (weak) id<SteepControllerDelegate> controllerDelegate;


+(SteepController *)sharedSteepController;

@property (nonatomic, getter=isBackgrounded) BOOL backgrounded;


-(void)ensureAuth;
-(void)startSteepTimerForMinutes:(NSNumber *)steepTime;
-(void)cancelSteepTimer;

-(void)addCupWithSize:(NSNumber *)size temperature:(NSNumber *)temperature caffeine:(NSNumber *)milligrams type:(enum TeaType)type recordCaffeineToHealthkit:(BOOL)recordCaffeine;
-(BOOL)isHealthDataAvailable;

-(void)queryHistoryWithCompletion:(void (^)(HKQuantityType *quantityType, NSArray *results, NSError *))completion;
@end
