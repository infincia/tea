//
//  SteepController.h
//  Tea
//
//  Created by steve on 10/25/14.
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

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
-(void)delegateShouldDisplayError:(NSString *)title withMessage:(NSString *)message;
@end

@interface SteepController : NSObject
+(SteepController *)sharedSteepController;
-(void)ensureAuth;
-(void)addCupWithSize:(NSNumber *)size temperature:(NSNumber *)temperature caffeine:(NSNumber *)milligrams type:(enum TeaType)type;
-(BOOL)isHealthDataAvailable;

-(void)queryHistoryWithCompletion:(void (^)(HKQuantityType *quantityType, NSArray *results, NSError *))completion;
@end
