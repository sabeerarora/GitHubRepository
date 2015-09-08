//
//  ViewController.h
//  Oracle
//
//  Created by Sabir Arora on 27/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <HealthKit/HealthKit.h>
#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (nonatomic,strong) HKHealthStore *healthStore;

@property (nonatomic, weak) IBOutlet UITextField *txtHeight;
@property (nonatomic, weak) IBOutlet UITextField *txtAge;
@property (nonatomic, weak) IBOutlet UITextField *txtWeight;


@end

