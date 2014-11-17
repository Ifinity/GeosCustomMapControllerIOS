//
//  AppDelegate.m
//  SimpleGeos
//
//  Created by Wojciech Chojnacki on 07.11.2014.
//  Copyright (c) 2014 GetIfinity. All rights reserved.
//

#import "AppDelegate.h"
#import <ifinitySDK/ifinitySDK.h>

#define GEOS_APP_ID @"..."
#define GEOS_SECRET @"..."

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[IFDataManager sharedManager] setClientID:GEOS_APP_ID secret:GEOS_SECRET];
    [[IFDataManager sharedManager] authenticateWithSuccess:^(IFOAuthCredential *credential) {
        NSLog(@"authenticated");
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
