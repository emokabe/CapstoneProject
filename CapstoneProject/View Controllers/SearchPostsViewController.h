//
//  SearchPostsViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/29/22.
//

#import <UIKit/UIKit.h>
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchPostsViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *postArray;
@property (nonatomic, strong) NSMutableArray *filteredPostArray;

@property (nonatomic, strong) APIManager *_apiManager;

@end

NS_ASSUME_NONNULL_END
