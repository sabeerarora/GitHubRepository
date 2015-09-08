//
//  Macros.h
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#ifndef Macros_h
#define Macros_h



//********************************************************************
#pragma mark - GENERAL

#define appDelegate             ((AppDelegate*) [UIApplication sharedApplication].delegate)
#define DEFAULTS                [NSUserDefaults standardUserDefaults]
#define API_MANAGER             [HOServiceManager sharedManager]

//********************************************************************
#pragma mark - LOADER

#define SHOW_NETWORK_ACTIVITY_INDICATOR [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HIDE_NETWORK_ACTIVITY_INDICATOR [UIApplication sharedApplication].networkActivityIndicatorVisible = NO


#define SHOW_LOADER_WITH_MESSAGE(message) [UTILS showLoadingViewWithTitle:message andMessage:@""]

//#define SHOW_LOADER [UTILS showLoadingView]
//#define HIDE_LOADER [UTILS hideLoadingView]

#define SHOW_LOADER SHOW_NETWORK_ACTIVITY_INDICATOR
#define HIDE_LOADER HIDE_NETWORK_ACTIVITY_INDICATOR







#endif /* Macros_h */
