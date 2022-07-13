//
//  PostCell.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface PostCell : UITableViewCell

@property (nonatomic, strong) Post *post;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *postText;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;

-(void)setPost:(Post *)post;


@end

NS_ASSUME_NONNULL_END
