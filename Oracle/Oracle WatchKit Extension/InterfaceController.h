//
//  InterfaceController.h
//  Oracle WatchKit Extension
//
//  Created by Sabir Arora on 27/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface InterfaceController : WKInterfaceController

@property (nonatomic,strong) HKHealthStore *healthStore;

@end
