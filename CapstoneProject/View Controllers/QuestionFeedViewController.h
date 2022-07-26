//
//  QuestionFeedViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuestionFeedViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

@property (nonatomic, strong) NSMutableArray *postArray;

@property (nonatomic, assign) BOOL firstFetchCall;

@end

NS_ASSUME_NONNULL_END
