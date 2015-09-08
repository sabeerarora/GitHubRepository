//
//  ViewController.m
//  Oracle
//
//  Created by Sabir Arora on 27/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import "HKHealthStore+AAPLExtensions.h"
#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController (){
    CMMotionManager *motionManager;

}

@end

@implementation ViewController

#pragma mark - Button event

-(IBAction)btnAgeSavePressed:(UIButton *)sender
{
    [API_MANAGER getUserDetails:API_MANAGER.healthOracleUserId withCompletion:^(BOOL result, NSDictionary *dict) {
        NSLog(@"USER DETAIL : %@",dict);
    }];
    
    [self.view endEditing:YES];
}

-(IBAction)btnHeightSavePressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self saveHeightIntoHealthStore:_txtHeight.text.doubleValue];
}

-(IBAction)btnWeightSavePressed:(UIButton *)sender
{
    [self.view endEditing:YES];
    [self saveWeightIntoHealthStore:_txtWeight.text.doubleValue];
}

#pragma mark - Reading HealthKit Data

- (void)updateUsersAgeLabel {
    // Set the user's age unit (years).
    
    NSError *error;
    NSDate *dateOfBirth = [self.healthStore dateOfBirthWithError:&error];
    
    if (!dateOfBirth) {
        NSLog(@"Either an error occured fetching the user's age information or none has been stored yet. In your app, try to handle this gracefully.");
        
        self.txtAge.placeholder = NSLocalizedString(@"Not available", nil);
    }
    else {
        // Compute the age of the user.
        NSDate *now = [NSDate date];
        
        NSDateComponents *ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:dateOfBirth toDate:now options:NSCalendarWrapComponents];
        
        NSUInteger usersAge = [ageComponents year];
        
        self.txtAge.text = [NSNumberFormatter localizedStringFromNumber:@(usersAge) numberStyle:NSNumberFormatterNoStyle];
        
        NSDateFormatter *df = [NSDateFormatter new];
        df.dateFormat = @"dd-MM-yyyy";
        self.txtAge.text = [df stringFromDate:dateOfBirth];
    }
}

- (void)updateUsersHeightLabel:(BOOL)withAlert
{
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    
    // Query to get the user's latest height, if it exists.
    [self.healthStore aapl_mostRecentQuantitySampleOfType:heightType
                                                predicate:nil
                                               completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
                                                   
       if (!mostRecentQuantity) {
           NSLog(@"Either an error occured fetching the user's height information or none has been stored yet. In your app, try to handle this gracefully.");
           
           dispatch_async(dispatch_get_main_queue(), ^{
               self.txtHeight.placeholder = NSLocalizedString(@"Not available", nil);
           });
       }
       else {
           // Determine the height in the required unit.
           HKUnit *heightUnit = [HKUnit inchUnit];
           double usersHeight = [mostRecentQuantity doubleValueForUnit:heightUnit];
           
           // Update the user interface.
           dispatch_async(dispatch_get_main_queue(), ^{
               NSLog(@" ");
               
               self.txtHeight.text = [NSNumberFormatter localizedStringFromNumber:@(usersHeight) numberStyle:NSNumberFormatterNoStyle];
               
               NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.watchSharedData"];
               [defaults setObject:self.txtHeight.text forKey:@"Height"];
               [defaults synchronize];
               
               
               if (withAlert) {
                   
                   [self doUpdateUserOnBackend];

                   [[[UIAlertView alloc] initWithTitle:@"Height" message:@"saved successfully !!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
               }
           });
       }
    }];
}


- (void)updateUsersWeightLabel:(BOOL)withAlert
{
    // Query to get the user's latest weight, if it exists.
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    [self.healthStore aapl_mostRecentQuantitySampleOfType:weightType
                                                predicate:nil
                                               completion:^(HKQuantity *mostRecentQuantity, NSError *error) {
        if (!mostRecentQuantity) {
            NSLog(@"Either an error occured fetching the user's weight information or none has been stored yet. In your app, try to handle this gracefully.");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.txtWeight.placeholder = NSLocalizedString(@"Not available", nil);
            });
        }
        else {
            // Determine the weight in the required unit.
//            HKUnit *weightUnit = [HKUnit poundUnit];
            HKUnit *weightUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
            
            double usersWeight = [mostRecentQuantity doubleValueForUnit:weightUnit];
            
            // Update the user interface.
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@" ");
                
                self.txtWeight.text = [NSNumberFormatter localizedStringFromNumber:@(usersWeight) numberStyle:NSNumberFormatterNoStyle];
                if (withAlert) {
                    
                    [self doUpdateUserOnBackend];

                    [[[UIAlertView alloc] initWithTitle:@"Weight" message:@"saved successfully !!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            });
        }
    }];
}

-(void)doUpdateUserOnBackend
{
    [API_MANAGER updateUserDetails:@{
                                     @"UserId"    :API_MANAGER.healthOracleUserId,
                                     @"Height"    :[NSNumber numberWithFloat:[_txtHeight.text floatValue]],
                                     @"Weight"    :[NSNumber numberWithFloat:[_txtWeight.text floatValue]],
                                     @"DOB"       :@"11/11/11",
                                     @"Gender"    :[NSNumber numberWithInt:1],
                                     }
                    withCompletion:^(BOOL result) {
                        NSLog(@"USER UPDATE : %@",result ? @"SUCCEDED" : @"FAIELD");
                        
                    }];

}

#pragma mark - Writing HealthKit Data

- (void)saveHeightIntoHealthStore:(double)height {
    // Save the user's height into HealthKit.
    HKUnit *inchUnit = [HKUnit inchUnit];
    HKQuantity *heightQuantity = [HKQuantity quantityWithUnit:inchUnit doubleValue:height];
    
    HKQuantityType *heightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *heightSample = [HKQuantitySample quantitySampleWithType:heightType quantity:heightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObject:heightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the height sample %@. In your app, try to handle this gracefully. The error was: %@.", heightSample, error);
            [[[UIAlertView alloc] initWithTitle:@"Height" message:@"failed to save !!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            //            abort();
        }
        
        [self updateUsersHeightLabel:YES];
    }];
}

- (void)saveWeightIntoHealthStore:(double)weight {
    // Save the user's weight into HealthKit.
//    HKUnit *poundUnit = [HKUnit poundUnit];
    HKUnit *poundUnit = [HKUnit gramUnitWithMetricPrefix:HKMetricPrefixKilo];
    
    HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:weight];
    
    HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    NSDate *now = [NSDate date];
    
    HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:now endDate:now];
    
    [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
        if (!success) {
            NSLog(@"An error occured saving the weight sample %@. In your app, try to handle this gracefully. The error was: %@.", weightSample, error);
            [[[UIAlertView alloc] initWithTitle:@"Weight" message:@"failed to save !!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            
            //            abort();
        }
        
        [self updateUsersWeightLabel:YES];
        
    }];
}

#pragma mark - HealthKit Permissions

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    
    return [NSSet setWithObjects:heightType, weightType, nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead
{
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    
    
    return [NSSet setWithObjects:heartRateType,heightType, weightType, birthdayType, biologicalSexType, nil];
}


#pragma mark - Refresh data

-(void)doRefreshData
{
    // Set up an HKHealthStore, asking the user for read/write permissions. The profile view controller is the
    // first view controller that's shown to the user, so we'll ask for all of the desired HealthKit permissions now.
    // In your own app, you should consider requesting permissions the first time a user wants to interact with
    // HealthKit data.
    
    if ([HKHealthStore isHealthDataAvailable]) {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes
                                                 readTypes:readDataTypes
                                                completion:^(BOOL success, NSError *error) {
                                                    if (!success) {
                                                        NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                                                        
                                                        return;
                                                    }
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        // Update the user interface based on the current user's health information.
                                                        [self updateUsersAgeLabel];
                                                        [self updateUsersHeightLabel:NO];
                                                        [self updateUsersWeightLabel:NO];
                                                    });
                                                }];
        
        
    }
    
    
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Health Oracle";
    

//    self.healthStore = [[HKHealthStore alloc] init];
//    [self doRefreshData];
//
//    
    appDelegate.appDidBecomeActiveHandler = ^{
        NSLog(@"__________________APP BECOME ACTIVE");
        [self doRefreshData];
    };
    
    [API_MANAGER createHealthOracleUserWithCompletion:^(BOOL completion) {

        if (completion)
        {
            NSLog(@"CREATED USER (%@) : %@", API_MANAGER.healthOracleUserId, completion ? @"SUCCESSFULLY" : @"FAILED TO CREATE !!");

            [API_MANAGER getUserDetails:API_MANAGER.healthOracleUserId withCompletion:^(BOOL result, NSDictionary *dict) {
                NSLog(@"CREATED USER DETAIL : %@",dict);
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
