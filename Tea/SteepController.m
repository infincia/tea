//
//  SteepController.m
//  Tea
//
//  Created by steve on 10/25/14.
//  Copyright (c) 2014 Infincia LLC. All rights reserved.
//

#import "SteepController.h"
@import HealthKit;



@interface SteepController  ()
@property HKHealthStore *store;
@property HKAuthorizationStatus authorization;
@end

@implementation SteepController



-(instancetype)init {
    if (self == [super init]) {
        self.store = [[HKHealthStore alloc] init];
        return self;
    }
    return nil;
}

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

+(SteepController *)sharedSteepController {
    static SteepController *staticSteepController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticSteepController = [[SteepController alloc] init];
    });
    return staticSteepController;
}

-(void)addCupWithSize:(NSNumber *)size temperature:(NSNumber *)temperature caffeine:(NSNumber *)milligrams type:(enum TeaType)type {
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

@end
