//
//  QuestionFeedViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/8/22.
//

#import <UIKit/UIKit.h>
#import "FBSDKCoreKit/FBSDKCoreKit.h"
#import "FBSDKLoginKit/FBSDKLoginKit.h"
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface QuestionFeedViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *logoutButton;

@property (nonatomic, strong) NSMutableArray *postArray;

@property (nonatomic, strong) APIManager *_apiManager;

@property (nonatomic, strong) NSMutableArray *postsToBeCached;

@end

NS_ASSUME_NONNULL_END
