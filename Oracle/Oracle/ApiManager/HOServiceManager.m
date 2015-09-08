//
//  HOServiceManager.m
//  Oracle
//
//  Created by Sabir Arora on 28/08/15.
//  Copyright © 2015 TAL. All rights reserved.
//

#import "HOServiceManager.h"

@implementation HOServiceManager

#pragma mark - Shared Manager

+(instancetype)sharedManager
{
    static HOServiceManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken,^{
        
        sharedManager = [[self alloc] init];
        
        sharedManager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
        sharedManager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers|NSJSONReadingAllowFragments];
        sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", nil];
        
        [sharedManager.requestSerializer setValue:@"applab" forHTTPHeaderField:@"user"];
        [sharedManager.requestSerializer setValue:@"czDAfjVfvUoRvsXAiPFftgkyAcjr9wBqTjPPCFHuGMxDaYTsQB" forHTTPHeaderField:@"password"];
        [sharedManager.requestSerializer setValue:@"Basic YXBwbGFiOmN6REFmalZmdlVvUnZzWEFpUEZmdGdreUFjanI5d0JxVGpQUENGSHVHTXhEYVlUc1FC" forHTTPHeaderField:@"Authorization"];
        [sharedManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"applab" password:@"czDAfjVfvUoRvsXAiPFftgkyAcjr9wBqTjPPCFHuGMxDaYTsQB"];


    });
    
    return sharedManager;
}



#pragma mark - CREATE USER

-(void)createHealthOracleUserWithCompletion:(void (^)(BOOL))completionHandler
{
    
    [self POST_dataOnURL:@"https://rocky-atoll-4317.herokuapp.com/user/"
          withParameters:@{
                         @"weight":[NSNumber numberWithFloat:50.0],
                         @"height":[NSNumber numberWithFloat:50.0],
                         @"dob":@"12/15/2014",
                         @"gender":[NSNumber numberWithInt:1],
                         @"dataOrigin":@"1"
                         }
             withLoading:YES
               withAlert:YES
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     NSString *userId = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"objectId"]];
                     _healthOracleUserId = userId ? userId : @"";
                  
                     completionHandler(_healthOracleUserId != nil);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     completionHandler(NO);
                 }];
}

#pragma mark - GET USER DETAILS

-(void)getUserDetails:(NSString *)userID
       withCompletion:(void (^)(BOOL,NSDictionary *))completionHandler
{
    
    [self GET_dataOnURL:[NSString stringWithFormat:@"https://rocky-atoll-4317.herokuapp.com/user/%@/",userID]
         withParameters:nil
            withLoading:YES
              withAlert:NO
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    NSString *responseString = responseObject;
                    
                    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[responseString dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
                    
                    completionHandler(YES,dict);

                }
                failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     NSLog(@"\n\n\n\n\n");
                     NSLog(@"FAILED_ERR : %@",error);
                     NSLog(@"\n\n");
                     NSLog(@"FAILED_RESP : %@",operation.responseString);
                    
                 completionHandler(NO,@{});

                }];
}


#pragma mark - UPDATE USER

-(void)updateUserDetails:(NSDictionary *)dictUserDetails
          withCompletion:(void (^)(BOOL))completionHandler
{
    NSString *url = [NSString stringWithFormat:@"https://rocky-atoll-4317.herokuapp.com/user/%@/",_healthOracleUserId];
    
    [self POST_dataOnURL:url
          withParameters:@{
                           @"UserID"    :[dictUserDetails objectForKey:@"UserId"],
                           @"weight"    :[dictUserDetails objectForKey:@"Weight"],
                           @"height"    :[dictUserDetails objectForKey:@"Height"],
                           @"dob"       :[dictUserDetails objectForKey:@"DOB"],
                           @"gender"    :[dictUserDetails objectForKey:@"Gender"],
                           }
             withLoading:YES
               withAlert:YES
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     
                     NSString *userId = [NSString stringWithFormat:@"%@",[responseObject objectForKey:@"objectId"]];
                     
                     _healthOracleUserId = userId ? userId : @"";
                     
                     completionHandler(YES);
                 }
                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     completionHandler(NO);
                 }];

}


#pragma mark - *********************** COMMON METHODS ***********************

- (void)POST_dataOnURL:(NSString *)url
       withParameters:(NSDictionary *)parameters
          withLoading:(BOOL)shouldDisplayLoading
            withAlert:(BOOL)shouldShowFailureAlert
              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
//    if (!IS_INTERNET_AVAILABLE) {
//        if (shouldShowFailureAlert)
//            [UTILS showMessage:NO_INTERNET_MESSAGE];
//        failure(nil, [UTILS errorWithMessage:NO_INTERNET_MESSAGE]);
//        return;
//    }
//    
    if (shouldDisplayLoading)
        SHOW_LOADER;
    
    
    [self POST:url
    parameters:parameters
       success:^(AFHTTPRequestOperation *operation, id responseObject) {
           
                NSLog(@"POST URL------ %@ -------", operation.request.URL.absoluteString);
                NSLog(@"SUCCESS : %@", responseObject);

                HIDE_LOADER;
                success(operation, responseObject);
       }
       failure:^(AFHTTPRequestOperation *operation, NSError *error) {
           
                NSLog(@"FAIL POST URL------ %@ -------", operation.request.URL.absoluteString);
                NSLog(@"ERROR   : %@", error.userInfo);
           
           HIDE_LOADER;
//           if (shouldShowFailureAlert)
//               [UTILS showError:error];
           
           failure(operation, error);
       }];
}

- (void)GET_dataOnURL:(NSString *)url
      withParameters:(NSDictionary *)parameters
         withLoading:(BOOL)shouldDisplayLoading
           withAlert:(BOOL)shouldShowFailureAlert
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
//    if (!IS_INTERNET_AVAILABLE) {
//        if (shouldShowFailureAlert)
//            [UTILS showMessage:NO_INTERNET_MESSAGE];
//        failure(nil, [UTILS errorWithMessage:NO_INTERNET_MESSAGE]);
//        return;
//    }
    
    if (shouldDisplayLoading)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            SHOW_LOADER;
        });
    }
    
    [self GET:url
   parameters:parameters
      success:^(AFHTTPRequestOperation *operation, id responseObject) {
          
              NSLog(@"GET URL------ %@ -------", operation.request.URL.absoluteString);
              NSLog(@"SUCCESS : %@", responseObject);
          
          if (shouldDisplayLoading)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  HIDE_LOADER;
              });
          }
          success(operation, responseObject);
      }
      failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          

              NSLog(@"FAIL GET URL------ %@ -------", operation.request.URL.absoluteString);
              NSLog(@"ERROR   : %@", error.userInfo);

          
          if (shouldDisplayLoading)
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  HIDE_LOADER;
              });
          }

//          if (shouldShowFailureAlert)
//              [UTILS showError:error];
          
          failure(operation, error);
      }];
}

@end
