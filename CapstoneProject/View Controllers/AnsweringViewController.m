//
//  AnsweringViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import "AnsweringViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "PostDetailsViewController.h"
#import "HTPressableButton.h"
#import "UIColor+HTColor.h"

@interface AnsweringViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *answerPlaceholder;

@property (strong, nonatomic) HTPressableButton *answerButton;

@end

@implementation AnsweringViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = self.postToAnswerInfo.titleContent;
    self.answeringToLabel.text = [NSString stringWithFormat:@"Answering %@'s question:", self.postToAnswerInfo.user_name];
    self.descriptionLabel.text = self.postToAnswerInfo.textContent;
    
    self.answerText.delegate = self;
    self.answerText.layer.borderWidth = 1.0;
    self.answerText.layer.borderColor = [[UIColor blackColor] CGColor];
  
    self.answerButton.translatesAutoresizingMaskIntoConstraints = YES;
    self.answerButton = [[HTPressableButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2 - 175, 500, 350, 40) buttonStyle:HTPressableButtonStyleRounded];
        self.answerButton.buttonColor = [UIColor ht_wetAsphaltColor];
        self.answerButton.shadowColor = [UIColor ht_midnightBlueColor];
        [self.answerButton setTitle:@"Post" forState:UIControlStateNormal];
    [self.answerButton addTarget:self action:@selector(didTapRespond:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.answerButton];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.answerText) {
        [self.answerPlaceholder setHidden:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.answerText &&
        [self.answerText.text isEqualToString:@""]) {
        [self.answerPlaceholder setHidden:NO];
    }
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapRespond:(id)sender {
    [self composeAnswer];
}


- (void)composeAnswer {
    NSString *messageWithDelimiters = [NSString stringWithFormat:@"%@%@%@", self.answerText.text, @"/0\n\n", self.postToAnswerInfo.post_id];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": messageWithDelimiters}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"Success!");
            [self getPostWithID:result[@"id"] completion:^(Post *post, NSError *err) {
                if (err) {
                    NSLog(@"Error getting post: %@", err.localizedDescription);
                } else {
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.delegate didComment:post];
                }
            }];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
}

- (void)getPostWithID:(NSString *)post_id completion:(void (^)(Post *, NSError *))completion {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", post_id]
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result);
            Post *post = [[Post alloc] initWithDictionary:result];
            completion(post, nil);
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
            completion(nil, error);
        }
    }];
}


@end
