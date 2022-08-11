//
//  ComposeViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/10/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ComposeViewControllerDelegate

-(void)didPost:(Post *)post;

@end

@interface ComposeViewController : UIViewController

@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;

@property (nonatomic, strong) APIManager *sharedManager;

@end

NS_ASSUME_NONNULL_END
