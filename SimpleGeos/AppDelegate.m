//
//  AppDelegate.m
//  SimpleGeos
//
//  Created by Wojciech Chojnacki on 07.11.2014.
//  Copyright (c) 2014 GetIfinity. All rights reserved.
//

#import "AppDelegate.h"
#import <ifinitySDK/ifinitySDK.h>

/**
 *  Fill with Application id and application secret from your geos.zone account. 
 *
 */
#define GEOS_APP_ID @"..."
#define GEOS_SECRET @"..."

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[IFDataManager sharedManager] setClientID:GEOS_APP_ID secret:GEOS_SECRET];
    [[IFDataManager sharedManager] authenticateWithSuccess:^(IFOAuthCredential *credential) {
        
        // This line should be triggered automaticly, based on my GPS coordinates,
        // At this stage, we don't want to complicate this, you can add GPS support at any time
        // IMPORTANT! Place your coordinates here
        [[IFDataManager sharedManager] loadDataForLocation:[[CLLocation alloc] initWithLatitude:52 longitude:21] withPublicVenues:NO block:^(BOOL success) {
            
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"Invalid authentication with error %@", error);
    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

@end
