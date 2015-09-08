//
//  InterfaceController.m
//  Carleep WatchKit Extension
//
//  Created by Arsene Huot on 06/08/2015.
//  Copyright © 2015 Arsene Huot. All rights reserved.
//

#import "InterfaceController.h"
@import HealthKit;
@import CoreMotion;

@interface InterfaceController() <HKWorkoutSessionDelegate>{
    CMMotionManager *motionManager;

}

@property (strong, nonatomic) HKHealthStore *hkStore;
@property (unsafe_unretained, nonatomic) IBOutlet WKInterfaceLabel *hearthLabel;
@property (nonatomic) HKQueryAnchor* anchor;
@property (strong, nonatomic) HKWorkoutSession *wsession;
@property (strong, nonatomic) HKQuery *query;
@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    self.hkStore = [HKHealthStore new];
    self.anchor = HKAnchoredObjectQueryNoAnchor;
    
    motionManager = [[CMMotionManager alloc]init];
    motionManager.accelerometerUpdateInterval = 5;
    
    if (motionManager.accelerometerAvailable == true)
    {
        [motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
                                            withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            NSLog(@"Called X:%.2f Y:%.2f Z:%.2f",accelerometerData.acceleration.x,accelerometerData.acceleration.y,accelerometerData.acceleration.z);
        }];
    }
    else {
    }
}

- (void)willActivate {
    [super willActivate];
    
    [self.hearthLabel setText:@"___"];
    [self checkHeartRatePerm];
}

- (void)checkHeartRatePerm
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (![HKHealthStore isHealthDataAvailable]) {
        return ;
    }
    if (![HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]) {
        return ;
    }
    
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    NSSet *types = [[NSSet alloc] initWithObjects:type, nil];
    
    [self.hkStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError * __nullable error) {
        if (success) {
            NSLog(@"success");
            [self startAction];
            [self performSelector:@selector(stopAction) withObject:nil afterDelay:120];
        }
    }];

//    if([self.hkStore authorizationStatusForType:type] == HKAuthorizationStatusSharingAuthorized){
//        [self startAction];
//        [self performSelector:@selector(stopAction) withObject:nil afterDelay:15];
//    }else{
//        [self.hkStore requestAuthorizationToShareTypes:nil readTypes:types completion:^(BOOL success, NSError * __nullable error) {
//            if (success) {
//                [self startAction];
//                [self performSelector:@selector(stopAction) withObject:nil afterDelay:15];
//            }
//        }];
//    }
}

#pragma mark - HKWorkoutSessionDelegate

- (void)workoutSession:(nonnull HKWorkoutSession *)workoutSession
      didChangeToState:(HKWorkoutSessionState)toState
             fromState:(HKWorkoutSessionState)fromState
                  date:(nonnull NSDate *)date
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    switch (toState) {
        case HKWorkoutSessionStateRunning:
            [self workoutDidStart:date];
            break;
        case HKWorkoutSessionStateEnded:
            [self workoutDidEnd:date];
            
        default:
            break;
    }
}

- (void)workoutSession:(nonnull HKWorkoutSession *)workoutSession didFailWithError:(nonnull NSError *)error
{
    NSLog(@"%@ %@",NSStringFromSelector(_cmd),error);
    [self checkHeartRatePerm];
}

- (void)workoutDidStart:(NSDate *)date
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.query = [self createHeartRateStreamingQuery];
    if (self.query) {
        [self.hkStore executeQuery:self.query];
    } else {
        [self checkHeartRatePerm];
    }
}

- (void)workoutDidEnd:(NSDate *)date
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (self.query) {
        [self.hkStore stopQuery:self.query];
    } else {
        //stop problem
    }
    [self.hearthLabel setText:@"__"];
}

- (HKQuery *)createHeartRateStreamingQuery
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    HKQuantityType *type = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKAnchoredObjectQuery *heartRateQuery = [[HKAnchoredObjectQuery alloc]
                                             initWithType:type
                                             predicate:nil
                                             anchor:self.anchor
                                             limit:HKObjectQueryNoLimit
                                             resultsHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
                                                 if (error) {
                                                     
                                                     // Perform proper error handling here...
                                                     NSLog(@"*** An error occured while performing the anchored object query. %@ ***",
                                                           error.localizedDescription);
                                                     
                                                     abort();
                                                 }
                                                 
                                                 self.anchor = newAnchor;
                                                 
                                                 HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
                                                 if (sample) {
                                                     double value = [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
                                                     [self.hearthLabel setText:[NSString stringWithFormat:@"%f",value]];
                                                     NSLog(@"%@",[NSString stringWithFormat:@"%0.0f",value]);
                                                 }
                                             }];
    
    [heartRateQuery setUpdateHandler:^(HKAnchoredObjectQuery * _Nonnull query, NSArray<__kindof HKSample *> * _Nullable sampleObjects, NSArray<HKDeletedObject *> * _Nullable deletedObjects, HKQueryAnchor * _Nullable newAnchor, NSError * _Nullable error) {
        self.anchor = newAnchor;
        HKQuantitySample *sample = (HKQuantitySample *)[sampleObjects lastObject];
        if (sample) {
            double value = [sample.quantity doubleValueForUnit:[HKUnit unitFromString:@"count/min"]];
            [self.hearthLabel setText:[NSString stringWithFormat:@"%0.0f",value]];
            NSLog(@"%@",[NSString stringWithFormat:@"%0.0f",value]);
        }
    }];
    
    return heartRateQuery;
}

#pragma mark - IBActions

- (IBAction)startAction
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    self.wsession = [[HKWorkoutSession alloc] initWithActivityType:HKWorkoutActivityTypeRunning locationType:HKWorkoutSessionLocationTypeIndoor];
    self.wsession.delegate = self;
    [self.hkStore startWorkoutSession:self.wsession];
}

- (IBAction)stopAction
{
    NSLog(@"%@",NSStringFromSelector(_cmd));
    [self.hkStore endWorkoutSession:self.wsession];
}
@end



