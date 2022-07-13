//
//  QuestionFeedViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import "QuestionFeedViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "FBLoginViewController.h"

@interface QuestionFeedViewController () <UITableViewDelegate, UITableViewDataSource>


@end

@implementation QuestionFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
        initWithGraphPath:@"/425184976239857/feed"
        parameters:@{ @"fields": @"from, created_time, message"}
        HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result[@"data"][0]);
            NSLog(@"%@",
                  [result[@"data"][0] class]);
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
    NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);
}


- (IBAction)didTapLogout:(id)sender {
    FBSDKLoginManager *logoutManager = [[FBSDKLoginManager alloc] init];
    [logoutManager logOut];
    
    NSLog(@"%@", [FBSDKAccessToken currentAccessToken]);

    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FBLoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"FBLoginViewController"];
    self.view.window.rootViewController = loginViewController; // substitute, less elegant
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    // TODO
    return NULL;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // TODO
    return 0;
}


@end
