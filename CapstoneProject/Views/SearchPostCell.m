//
//  SearchPostCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/1/22.
//

#import "SearchPostCell.h"
#import "DateTools.h"
#import "NSDate+DateTools.h"
#import "UIColor+HTColor.h"

@implementation SearchPostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setSearchPostCell:(PFObject *)post {
    _post = post;
    
    self.titleLabel.text = post[@"title"];
    self.bodyText.text = post[@"message"];
    self.courseLabel.text = post[@"course"];
    self.viewTimeLabel.text = [NSString stringWithFormat:@"%@%@%@", @"Viewed ", ((NSDate *)post[@"read_date"]).shortTimeAgoSinceNow, @" ago"];
    self.viewTimeLabel.textColor = [UIColor ht_lavenderDarkColor];
}

@end
