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

- (void)setComment:(Post *)post {
    _post = post;
    
    self.nameLabel.text = post.user_name;
    self.timestampLabel.text = post.post_date.shortTimeAgoSinceNow;
    self.answerLabel.text = post.textContent;
}

@end
