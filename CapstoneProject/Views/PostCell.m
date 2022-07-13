//
//  PostCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setPost:(Post *)post {
    _post = post;
    
    self.nameLabel.text = post.user_name;
    self.postText.text = post.textContent;
    self.dateLabel.text = post.post_createdAt;
    self.timestampLabel.text = post.post_date.shortTimeAgoSinceNow;
    NSLog(@"message = %@", self.postText.text);
}

@end
