//
//  HOServiceManager.h
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface HOServiceManager : AFHTTPRequestOperationManager

#pragma mark - Properties

@property (nonatomic,strong) HOUser *user;
@property (nonatomic,strong) NSString *healthOracleUserId;


#pragma mark - Methods

+(instancetype)sharedManager;

-(void)createHealthOracleUserWithCompletion:(void(^)(BOOL))completionHandler;

-(void)updateUserDetails:(NSDictionary *)dictUserDetails
          withCompletion:(void (^)(BOOL))completionHandler;

-(void)getUserDetails:(NSString *)userID
       withCompletion:(void (^)(BOOL,NSDictionary *))completionHandler;

@end
