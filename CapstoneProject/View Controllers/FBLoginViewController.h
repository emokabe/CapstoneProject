//
//  FBLoginViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface FBLoginViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *appName;
@property (weak, nonatomic) IBOutlet UIImageView *appLogo;
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *loginButton;


@end

NS_ASSUME_NONNULL_END
