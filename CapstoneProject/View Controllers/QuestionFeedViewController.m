//
//  QuestionFeedViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import "QuestionFeedViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"

@interface QuestionFeedViewController ()
@property (weak, nonatomic) IBOutlet UILabel *successMessage;

@end

@implementation QuestionFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapLogout:(id)sender {
    
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
