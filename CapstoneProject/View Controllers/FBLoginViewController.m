//
//  FBLoginViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import "FBLoginViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "QuestionFeedViewController.h"

@interface FBLoginViewController () <FBSDKLoginButtonDelegate>

@end

@implementation FBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginButton.delegate = self;
    self.loginButton.permissions = @[@"public_profile", @"email", @"user_friends"];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSLog(@"Hi!");
    
    // if the user is already logged in
    if ([FBSDKAccessToken currentAccessToken] != nil) {
        NSLog(@"User ID = %@", [FBSDKAccessToken currentAccessToken].userID);
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginSuccessPage"]; // loginSuccessPage
        [self showViewController:rootViewController sender:nil];
    }
}

- (void)loginButton:(FBSDKLoginButton * _Nonnull)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult * _Nullable)result error:(NSError * _Nullable)error {
    if (error) {
        NSLog(@"😫😫😫 Error logging in: %@", error.localizedDescription);
        return;
    }
    
    if (result.token) {
        // Get user access token
        //FBSDKAccessToken *token = result.token;
        
        // or NSLog(@"Token = %@", token);
        NSLog(@"Token = %@", [FBSDKAccessToken currentAccessToken].tokenString);
        NSLog(@"User ID = %@", [FBSDKAccessToken currentAccessToken].userID);
        
        [self goToTabOnLogin];
    }
}

- (void)goToTabOnLogin {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginSuccessPage"];
    self.view.window.rootViewController = rootViewController;
    
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *course_id = [saved stringForKey:@"bogus"];
    //NSString *course_id = [saved stringForKey:@"currentCourse"];
    
    if (!course_id) {
        [rootViewController setSelectedIndex:1];
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton * _Nonnull)loginButton {
    NSLog(@"User is logged out");
}

@end
