//
//  ComposeViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/10/22.
//

#import "ComposeViewController.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "Post.h"
#import "Parse/Parse.h"

@interface ComposeViewController () <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *titleText;
@property (weak, nonatomic) IBOutlet UITextView *postText;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (weak, nonatomic) IBOutlet UILabel *titlePlaceholder;
@property (weak, nonatomic) IBOutlet UILabel *postPlaceholder;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleText.layer.borderWidth = 1.0;
    self.titleText.layer.borderColor = [[UIColor blackColor] CGColor];
    self.postText.layer.borderWidth = 1.0;
    self.postText.layer.borderColor = [[UIColor blackColor] CGColor];
    self.titleText.delegate = self;
    self.postText.delegate = self;
    self.postButton.translatesAutoresizingMaskIntoConstraints = YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (textView == self.titleText) {
        [self.titlePlaceholder setHidden:YES];
    } else if (textView == self.postText) {
        [self.postPlaceholder setHidden:YES];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == self.titleText) {
        [self.titlePlaceholder setHidden:NO];
    } else if (textView == self.postText) {
        [self.postPlaceholder setHidden:NO];
    }
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)didTapPost:(id)sender {
    [self composePost];
}

-(void)composePost {
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    NSString *courseId = [saved stringForKey:@"currentCourse"];
    
    NSString *messageWithDelimiters = [NSString stringWithFormat:@"%@%@%@%@%@", self.titleText.text, @"/0\n\n", self.postText.text, @"/0\n\n", courseId];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": messageWithDelimiters}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            [self getPostWithID:result[@"id"] completion:^(Post *post, NSError *err) {
                if (err) {
                    NSLog(@"Error getting post: %@", err.localizedDescription);
                } else {
                    NSLog(@"Success!");
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [self.delegate didPost:post];
                }
            }];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
    
}

- (Post *)createPostObject: (NSString* _Nullable)post_id {
    
    __block Post *newPost = nil;
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:[NSString stringWithFormat:@"/%@", post_id]
                                  parameters:@{ @"fields": @"from, created_time, message"}
                                  HTTPMethod:@"GET"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", result);
            newPost = [[Post alloc] initWithDictionary:result];
        } else {
            NSLog(@"Error posting to feed: %@", error.localizedDescription);
        }
    }];
    
    NSLog(@"New post is %@", newPost);
    return newPost;
}

-(void)getPostWithID:(NSString *)post_id completion:(void (^)(Post *, NSError *))completion {
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
