//
//  SelectCourseViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectCourseViewController : UIViewController

@property (nonatomic, strong) NSMutableArray *courseArray;

@property (nonatomic, strong) APIManager *sharedManager;

@end

NS_ASSUME_NONNULL_END
