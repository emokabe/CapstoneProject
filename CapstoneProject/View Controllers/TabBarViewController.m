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
    
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    appearance.backgroundColor = [UIColor ht_cloudsColor];
    self.tabBar.standardAppearance = appearance;
    self.tabBar.scrollEdgeAppearance = self.tabBar.standardAppearance;
    self.tabBar.tintColor = [UIColor ht_wetAsphaltColor];
}

@end
