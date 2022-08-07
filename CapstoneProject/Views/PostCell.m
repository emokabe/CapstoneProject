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
    self.postText.text = post.textContent;
    self.dateLabel.text = post.post_createdAt;
    self.timestampLabel.text = post.post_date.shortTimeAgoSinceNow;
    [self setRandomColor];
}

- (void)setRandomColor {
    NSArray *colors = @[[AppColors lightPink],
                        [AppColors lightLime],
                        [AppColors lightOrange],
                        [AppColors lightSeaFoam],
                        [AppColors paleBlue]
    ];
    NSInteger randIndex = arc4random_uniform([colors count]);
    self.colorBar.backgroundColor = colors[randIndex];
}

@end
