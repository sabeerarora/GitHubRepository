//
//  AppDelegate.h
//  Oracle
//
//  Created by Sabir Arora on 27/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) void (^appDidBecomeActiveHandler) (void);


@end

