//
//  AnsweringViewController.h
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/20/22.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnsweringViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *answeringToLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UITextView *answerText;
@property (weak, nonatomic) IBOutlet UIButton *postButton;
@property (strong, nonatomic) Post *postToAnswerInfo;

@end

NS_ASSUME_NONNULL_END
