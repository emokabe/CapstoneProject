//
//  PostCell.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "UIColor+HTColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell

@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postText;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UIView *colorBar;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

-(void)setPost:(Post *)post;


@end

NS_ASSUME_NONNULL_END
