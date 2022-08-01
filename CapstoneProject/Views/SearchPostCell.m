//
//  SearchPostCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/1/22.
//

#import "SearchPostCell.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"

@implementation SearchPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setSearchPostCell:(PFObject *)post {
    _post = post;
    
    self.titleLabel.text = post[@"title"];
    self.bodyText.text = post[@"message"];
    self.courseLabel.text = post[@"course"];
    self.viewTimeLabel.text = ((NSDate *)post[@"read_date"]).shortTimeAgoSinceNow;
}

@end
