//
//  FBLoginViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import "FBLoginViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"

@interface FBLoginViewController ()

@end

@implementation FBLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FBSDKLoginButton *loginButton = [[FBSDKLoginButton alloc] init];
        // Optional: Place the button in the center of your view.
        loginButton.center = self.view.center;
        [self.view addSubview:loginButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
