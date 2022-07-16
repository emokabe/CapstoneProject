//
//  SelectCourseViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/15/22.
//

#import "SelectCourseViewController.h"
#import "CourseCell.h"

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
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Course"];
    //[query whereKey:@"likesCount" greaterThan:@100];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *courses, NSError *error) {
        if (courses != nil) {
            NSLog(@"Type: %@", [courses class]);
            NSLog(@"Count = %lu", (unsigned long)courses.count);
            self.courseArray = [NSMutableArray arrayWithArray:courses];
            NSLog(@"Second course: %@", self.courseArray[1]);
        } else {
            NSLog(@"%@", error.localizedDescription);
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
    
    [cell setCourse:self.courseArray[indexPath.row]];  // CHECK
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //NSLog(@"Count Later = %lu", (unsigned long)self.courseArray.count);
    //return self.courseArray.count;
    return 2;
}

@end
