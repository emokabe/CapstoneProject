//
//  SelectCourseViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/15/22.
//

#import "SelectCourseViewController.h"
#import "CourseCell.h"
#import "QuestionFeedViewController.h"

@interface SelectCourseViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SelectCourseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self fetchCourses];
}

- (void)fetchCourses {
    [self getCoursesWithCompletion:^(NSArray *courses, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error.localizedDescription);
        } else {
            self.courseArray = [NSMutableArray arrayWithArray:courses];
            [self.tableView reloadData];
        }
    }];
}


- (void)getCoursesWithCompletion:(void(^)(NSArray *courses, NSError *error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Course"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *result, NSError *error) {
        if (result != nil) {
            NSMutableArray *courses = [NSMutableArray arrayWithArray:result];
            completion(courses, nil);
        } else {
            completion(nil, error);
        }
    }];
}

/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    CourseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CourseCell"];

    [cell setCourseCell:self.courseArray[indexPath.row]];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.courseArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *objectId = ((PFObject *) self.courseArray[indexPath.row]).objectId;
    NSUserDefaults *saved = [NSUserDefaults standardUserDefaults];
    [saved setObject:objectId forKey:@"currentCourse"];

    
    //QuestionFeedViewController *questionfeedvc = self.tabBarController.viewControllers[0];
    
    UIView * fromView = self.tabBarController.selectedViewController.view;
    UIView * toView = self.tabBarController.viewControllers[0].view;
    
    [UIView transitionFromView:fromView
                            toView:toView
                          duration:0.5
                           options: UIViewAnimationOptionTransitionCrossDissolve
                        completion:^(BOOL finished) {
                            if (finished) {
                                [self.tabBarController setSelectedIndex:0];
                            }
    }];
}

@end
