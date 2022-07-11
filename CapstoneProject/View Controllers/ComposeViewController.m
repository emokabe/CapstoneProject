//
//  ComposeViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/10/22.
//

#import "ComposeViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"

@interface ComposeViewController ()
@property (weak, nonatomic) IBOutlet UITextView *postText;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapPost:(id)sender {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
        initWithGraphPath:@"/425184976239857/feed"
               parameters:@{ @"message": self.postText.text,}
               HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result);
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
