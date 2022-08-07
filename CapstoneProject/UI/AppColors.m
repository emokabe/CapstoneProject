//
//  AppColors.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 8/6/22.
//

#import "AppColors.h"

@implementation AppColors

+ (UIColor *)paleBlue {
    return [UIColor colorWithRed: 0.75 green: 0.89 blue: 1.00 alpha: 1.00];
}

+ (UIColor *)lightPink {
    return [UIColor colorWithRed: 1.00 green: 0.70 blue: 0.77 alpha: 1.00];
}

+ (UIColor *)lightOrange {
    return [UIColor colorWithRed: 1.00 green: 0.80 blue: 0.58 alpha: 1.00];
}

+ (UIColor *)lightMint {
    return [UIColor colorWithRed: 0.75 green: 1.00 blue: 0.78 alpha: 1.00];
}

+ (UIColor *)lightSeaFoam {
    return [UIColor colorWithRed: 0.60 green: 1.00 blue: 0.91 alpha: 1.00];
}

+ (UIColor *)lavender {
    return [UIColor colorWithRed: 0.88 green: 0.74 blue: 1.00 alpha: 1.00];
}

+ (UIColor *)lightMarigold {
    return [UIColor colorWithRed: 1.00 green: 0.92 blue: 0.56 alpha: 1.00];
}

+ (UIColor *)randomColor {
    NSArray *colors = @[[AppColors paleBlue],
                        [AppColors lightPink],
                        [AppColors lightOrange],
                        [AppColors lightMint],
                        [AppColors lightSeaFoam],
                        [AppColors lavender],
                        [AppColors lightMarigold]];
    NSInteger randIndex = arc4random_uniform((uint32_t)[colors count]);
    return colors[randIndex];
}

@end
