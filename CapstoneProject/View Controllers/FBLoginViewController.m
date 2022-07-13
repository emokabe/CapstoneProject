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
    // Do any additional setup after loading the view.
    
    self.loginButton.delegate = self;
    self.loginButton.permissions = @[@"public_profile", @"email", @"user_friends"];
    
}

// TODO: write viewWillAppear method

- (IBAction)didTapLogin:(id)sender {
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    
    [login logInWithPermissions:@[@"public_profile", @"email", @"user_posts", @"publish_to_groups", @"groups_show_list", @"groups_access_member_info", @"user_managed_groups"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
        if (error) {
            NSLog(@"😫😫😫 Error getting home timeline: %@", error.localizedDescription);
        } else if (result.declinedPermissions.count != 0) {
            NSLog(@"Permissions declined by user");
        } else {
            [self performSegueWithIdentifier:@"loginSegue" sender:nil];
        }
    }];
    
    // if press cancel instead of continue at login
    // continues with segue, not getting right error
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}
*/

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
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginSuccessPage"];
        self.view.window.rootViewController = rootViewController;
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton * _Nonnull)loginButton {
    NSLog(@"User is logged out");
}

@end
