//
//  Post.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/11/22.
//

#import "Post.h"

@implementation Post


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSLog(@"%@", dictionary);
        self.user_id = dictionary[@"from"][@"id"];
        self.user_name = dictionary[@"from"][@"name"];
        
        NSLog(@"This is my message: %@", dictionary[@"message"]);
        NSArray *arrayOfComponents = [dictionary[@"message"] componentsSeparatedByString:@"/0\n\n"];
        if ([arrayOfComponents count] == 3) {
            self.titleContent = arrayOfComponents[0];
            self.textContent = arrayOfComponents[1];
            self.courses = arrayOfComponents[2];
        } else {
            self.titleContent = [NSMutableString stringWithString:@""];
            self.textContent = [NSMutableString stringWithString:@""];
        }
        
        self.post_id = dictionary[@"id"];
        
        NSString *createdAtOriginalString = dictionary[@"created_time"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";     // Configure the input format to parse the date string
        
        NSDate *date = [formatter dateFromString:createdAtOriginalString];     // Convert String to Date
        self.post_date = date;
        
        formatter.dateStyle = NSDateFormatterShortStyle;     // Configure output format
        formatter.timeStyle = NSDateFormatterNoStyle;
        self.post_createdAt = [formatter stringFromDate:date];     // Convert Date to String
    }
    return self;
}

+ (NSMutableArray *)postsWithArray:(NSArray *)dictionaries {
    NSMutableArray *posts = [NSMutableArray array];
    NSLog(@"postsWithArray posts: %@", posts);
    for (NSDictionary *dictionary in dictionaries) {
        NSLog(@"postsWithArray dictionary: %@", dictionary);
        Post *post = [[Post alloc] initWithDictionary:dictionary];
        if (![post.titleContent isEqualToString:@""] && ![post.textContent isEqualToString: @""]) {
            [posts addObject:post];
        }
    }
    NSLog(@"postsWithArray return value: %@", posts);
    return posts;
}

@end
