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
@property (nonatomic, strong) NSMutableArray *recommendedArray;
@property (assign, nonatomic) NSString *filter_string;

@property (assign, nonatomic) NSPredicate *selected_predicate;

@property (nonatomic, strong) APIManager *sharedManager;

@property (nonatomic, strong) NSMutableDictionary *wordCountDict;

@property (nonatomic, strong) NSMutableDictionary *toSort;

@end

NS_ASSUME_NONNULL_END
