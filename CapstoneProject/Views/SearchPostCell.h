//
//  SearchPostCell.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/1/22.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchPostCell : UITableViewCell

@property (nonatomic, strong) PFObject *post;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bodyText;
@property (weak, nonatomic) IBOutlet UILabel *courseLabel;
@property (weak, nonatomic) IBOutlet UILabel *viewTimeLabel;

- (void)setSearchPostCell:(PFObject *)post;

@end

NS_ASSUME_NONNULL_END
