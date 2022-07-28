//
//  CommentCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/28/22.
//

#import "CommentCell.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setComment:(Comment *)comment {
    _comment = comment;
    
    self.nameLabel.text = comment.user_name;
    self.timestampLabel.text = comment.post_date.shortTimeAgoSinceNow;
}

@end
