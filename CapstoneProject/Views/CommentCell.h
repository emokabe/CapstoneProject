//
//  CommentCell.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/28/22.
//

#import <UIKit/UIKit.h>
#import "Comment.h"

NS_ASSUME_NONNULL_BEGIN

@interface CommentCell : UITableViewCell

@property (nonatomic, strong) Comment *comment;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;

@end

NS_ASSUME_NONNULL_END
