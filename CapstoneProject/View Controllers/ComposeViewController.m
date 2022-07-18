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
    [self composePost];
}

-(void)composePost {
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:@"/425184976239857/feed"
                                  parameters:@{ @"message": self.postText.text,}
                                  HTTPMethod:@"POST"];
    
    [request startWithCompletion:^(id<FBSDKGraphRequestConnecting>  _Nullable connection, id  _Nullable result, NSError * _Nullable error) {
        if (!error) {
            [self getPostWithID:result[@"id"] completion:^(Post *post, NSError *err) {
                if (err) {
                    NSLog(@"Error getting post: %@", err.localizedDescription);
                } else {
                    NSLog(@"Success!");
                    
                    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
                    NSString *courseId = [saved stringForKey:@"currentCourse"];
                    NSLog(@"Current course: %@", courseId);
                    
                    PFObject *newPost = [PFObject objectWithClassName:@"Post"];
                    newPost[@"course_ObjectId"] = courseId;
                    //gameScore[@"comments"] = [[NSMutableArray alloc] init];
                    [newPost saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            NSLog(@"Object saved!");
                        } else {
                            NSLog(@"Error: %@", error.description);
                        }
                    }];
                    
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
