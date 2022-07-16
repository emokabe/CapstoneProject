//
//  CourseCell.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/15/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface CourseCell : UITableViewCell

@property (nonatomic, strong) PFObject *course;
@property (weak, nonatomic) IBOutlet UILabel *courseName;
@property (weak, nonatomic) IBOutlet UILabel *courseAbbr;

- (void)setCourseCell:(PFObject *)course;

@end

NS_ASSUME_NONNULL_END
