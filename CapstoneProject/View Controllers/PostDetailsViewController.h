//
//  PostDetailsViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "APIManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailsViewController : UIViewController <UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (strong, nonatomic) Post *postInfo;
@property (nonatomic, strong) APIManager *sharedManager;
@property (nonatomic, strong) NSMutableArray *commentArray;

@end

NS_ASSUME_NONNULL_END
