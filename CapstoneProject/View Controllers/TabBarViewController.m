//
//  TabBarViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/14/22.
//

#import "TabBarViewController.h"
#import "UIColor+HTColor.h"

@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBar.barTintColor = UIColor.whiteColor;
    
    UINavigationBarAppearance *navigationBarAppearance = [[UINavigationBarAppearance alloc] init];
    [navigationBarAppearance configureWithOpaqueBackground];
    navigationBarAppearance.backgroundColor = [UIColor ht_ashDarkColor];
    [[UINavigationBar appearance] setStandardAppearance:navigationBarAppearance];
    [[UINavigationBar appearance] setCompactAppearance:navigationBarAppearance];
    [[UINavigationBar appearance] setScrollEdgeAppearance:navigationBarAppearance];
}

@end
