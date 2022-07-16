//
//  AppDelegate.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/5/22.
//

#import "AppDelegate.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "Parse/Parse.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [FBSDKLoginButton class];
    [FBSDKApplicationDelegate.sharedInstance application:application didFinishLaunchingWithOptions:launchOptions];
    
    ParseClientConfiguration *config = [ParseClientConfiguration  configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        
        configuration.applicationId = @"Ah8NtLvAUjjjk6zIro3QeC8S3g3bYmfSQT2CCuwX";
        configuration.clientKey = @"WH4s0Z5NL8Aa2BxC202b1eqwLgtVAOBCnTpEF9u4";
        configuration.server = @"https://parseapi.back4app.com";
    }];
    
    [Parse initializeWithConfiguration:config];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(nonnull NSURL *)url options:(nonnull NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    BOOL handled;
    
    if ([options[UIApplicationOpenURLOptionsSourceApplicationKey] isKindOfClass:[NSString class]]) {
        handled = [FBSDKApplicationDelegate.sharedInstance application:application openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    } else {
        handled = [FBSDKApplicationDelegate.sharedInstance application:application openURL:url sourceApplication:nil annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    
    return handled;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
