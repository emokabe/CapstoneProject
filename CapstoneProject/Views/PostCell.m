//
//  PostCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import "PostCell.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"
#import "AppColors.h"
#import "UIColor+HTColor.h"
#import "FBSDKCoreKit/FBSDKCoreKit.h"


@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setPost:(Post *)post {
    _post = post;
    
    self.titleLabel.text = post.titleContent;
    self.nameLabel.text = post.user_name;
    self.nameLabel.textColor = [UIColor ht_wetAsphaltColor];
    self.postText.text = post.textContent;
    self.dateLabel.text = post.post_createdAt;
    self.dateLabel.textColor = [UIColor ht_lavenderDarkColor];
    self.timestampLabel.text = post.post_date.shortTimeAgoSinceNow;
    self.timestampLabel.textColor = [UIColor ht_lavenderDarkColor];
    
    NSLog(@"profile picture: %@", post.profilePic_url);
    NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:post.profilePic_url]];
    self.profilePic.image = [UIImage imageWithData: imageData];
    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.height/2;
    
    [self setRandomColor];
}

- (void)setRandomColor {
    self.colorBar.backgroundColor = [AppColors randomColor];
}

@end
