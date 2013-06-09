//
//  HGAppDelegate.m
//  kryptonite
//
//  Created by Brian McManus on 6/8/13.
//  Copyright (c) 2013 Brian McManus. All rights reserved.
//

#import "HGAppDelegate.h"
#import <Parse/Parse.h>

@interface HGAppDelegate()
@property (nonatomic, strong) NSDictionary *pushPayload;
@end

@implementation HGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:HGParseAppId
                  clientKey:HGParseClientKey];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    self.pushPayload = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateBackground) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HGIncidentNotification object:self userInfo:userInfo];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:HGIncidentNotificationForeground object:self userInfo:userInfo];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"Registered for notifications.");
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Unable to register for notifications: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (self.pushPayload) {
        [[NSNotificationCenter defaultCenter] postNotificationName:HGIncidentNotification object:self userInfo:self.pushPayload];
        self.pushPayload = nil;
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
