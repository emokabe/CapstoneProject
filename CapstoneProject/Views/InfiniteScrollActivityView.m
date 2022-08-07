//
//  InfiniteScrollActivityView.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/6/22.
//

#import "InfiniteScrollActivityView.h"

@implementation InfiniteScrollActivityView

UIActivityIndicatorView* activityIndicatorView;
static CGFloat _defaultHeight = 60.0;

+ (CGFloat)defaultHeight{
    return _defaultHeight;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self setupActivityIndicator];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setupActivityIndicator];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    activityIndicatorView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
}

- (void)setupActivityIndicator{
    activityIndicatorView = [[UIActivityIndicatorView alloc] init];
    activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleMedium;
    activityIndicatorView.hidesWhenStopped = YES;
    [self addSubview:activityIndicatorView];
}

-(void)stopAnimating{
    [activityIndicatorView stopAnimating];
    self.hidden = YES;
}

-(void)startAnimating{
    self.hidden = NO;
    [activityIndicatorView startAnimating];
}

@end
