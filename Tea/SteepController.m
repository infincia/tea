//
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

@import HealthKit;


#import "SteepController.h"


@interface SteepController  () {
    NSTimeInterval initialTimeSeconds;
    NSTimeInterval remainingTimeSeconds;
}

@property NSTimer *steepTimer;


@property UIBackgroundTaskIdentifier backgroundTask;
@property NSTimeInterval allowedBackgroundTime;
-  (void)backgroundTaskExpired;
-  (void)enterBackground;

@property HKHealthStore *store;
@property HKAuthorizationStatus authorization;

@end

@implementation SteepController



-(instancetype)init {
    if (self == [super init]) {
        self.backgroundTask = UIBackgroundTaskInvalid;
        self.backgrounded = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground)   name:UIApplicationDidEnterBackgroundNotification    object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground)  name:UIApplicationWillEnterForegroundNotification   object:nil];
        //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminate)        name:UIApplicationWillTerminateNotification         object:nil];
        self.store = [[HKHealthStore alloc] init];
        return self;
    }
    return nil;
}


+(SteepController *)sharedSteepController {
    static SteepController *staticSteepController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticSteepController = [[SteepController alloc] init];
    });
    return staticSteepController;
}






#pragma mark
#pragma mark Steep Timer

-(void)startSteepTimerForMinutes:(NSNumber *)steepTime {
    initialTimeSeconds = [steepTime integerValue] * 60;
    remainingTimeSeconds = initialTimeSeconds;
    self.steepTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
    [self.timerDelegate steepTimeRemaining:remainingTimeSeconds outOfSteepTime:initialTimeSeconds];

}

-(void)cancelSteepTimer {
    if (self.steepTimer.isValid) [self.steepTimer invalidate];
}


-(void)tick {
    [self.timerDelegate steepTimeRemaining:remainingTimeSeconds outOfSteepTime:initialTimeSeconds];
    if (remainingTimeSeconds > 0) {
        remainingTimeSeconds--;
    }
    else {
        [self.steepTimer invalidate];
        [self.controllerDelegate steepDidFinish:self];
    }
}


#pragma mark
#pragma mark HealthKit

-(void)ensureAuth {
    if ([self isHealthDataAvailable]) {
        HKQuantityType *caffeineType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];

        NSSet *types = [NSSet setWithArray:@[caffeineType]];
        [self.store requestAuthorizationToShareTypes:types readTypes:types completion:^(BOOL success, NSError *error) {
            if (!success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                });
                return;
            }
            self.authorization = [self.store authorizationStatusForType:caffeineType];
            switch (self.authorization) {
                case HKAuthorizationStatusNotDetermined:
                    break;
                case HKAuthorizationStatusSharingAuthorized:
                    break;
                case HKAuthorizationStatusSharingDenied:
                    dispatch_async(dispatch_get_main_queue(), ^{

                    });
                    break;
                default:
                    break;
            }
        }];
    }
}

-(BOOL)isHealthDataAvailable {
    return [HKHealthStore isHealthDataAvailable];
}

-(void)addCupWithSize:(NSNumber *)size temperature:(NSNumber *)temperature caffeine:(NSNumber *)milligrams type:(enum TeaType)type recordCaffeineToHealthkit:(BOOL)recordCaffeine {
    if (!recordCaffeine) return;
    if (!self.authorization == HKAuthorizationStatusSharingAuthorized) {
        return;
    }
    HKUnit *milligramUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixMilli];
    HKQuantity *caffeineQuantity = [HKQuantity quantityWithUnit:milligramUnit doubleValue:[milligrams doubleValue]];

    HKQuantityType *caffeineType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    NSDate *now = [NSDate date];

    HKQuantitySample *caffeineSample = [HKQuantitySample quantitySampleWithType:caffeineType quantity:caffeineQuantity startDate:now endDate:now];

    [self.store saveObject:caffeineSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the caffeine sample %@. In your app, try to handle this gracefully. The error was: %@.", caffeineSample, error);
            //abort();
        }
    }];
}

-(void)queryHistoryWithCompletion:(void (^)(HKQuantityType *quantityType, NSArray *results, NSError *))completion {
    NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];
    HKQuantityType *caffeineType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryCaffeine];
    // Since we are interested in retrieving the user's latest sample, we sort the samples in descending order, and set the limit to 1. We are not filtering the data, and so the predicate is set to nil.
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:caffeineType predicate:nil limit:HKObjectQueryNoLimit sortDescriptors:@[timeSortDescriptor] resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
        if (!results) {
            if (completion) {
                completion(caffeineType, nil, error);
            }
            return;
        }

        if (completion) {
            completion(caffeineType, results, error);
        }
    }];

    [self.store executeQuery:query];
}







#pragma mark
#pragma mark background callbacks

-(void)willEnterForeground {
    NSLog(@"App coming back to foreground");
    [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
    self.backgroundTask = UIBackgroundTaskInvalid;
    self.backgrounded = NO;
}

-(void)didEnterBackground{
    NSLog(@"Entering background");
    self.backgrounded = YES;
    [self enterBackground];
}

- (void)backgroundTaskExpired {
    NSLog(@"App background task expired");
    if (!self.backgroundTask == UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTask];
        self.backgroundTask = UIBackgroundTaskInvalid;
    }
}

-(void)enterBackground {
    NSLog(@"App entering background");
    if (self.backgroundTask == UIBackgroundTaskInvalid) {
        NSLog(@"App starting new background task");
        self.backgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [self backgroundTaskExpired];
        }];
    }
}

@end
