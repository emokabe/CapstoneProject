//
//  CourseCell.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/15/22.
//

#import "CourseCell.h"

@implementation CourseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setCourseCell:(PFObject *)course {
    _course = course;
    
    self.courseName.text = course[@"course_name"];
    self.courseAbbr.text = course[@"course_abbr"];
}


@end
