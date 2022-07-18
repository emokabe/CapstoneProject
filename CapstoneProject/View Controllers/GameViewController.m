//
//  GameViewController.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/17/22.
//

#import "GameViewController.h"
#import "SpriteKit/SpriteKit.h"

@interface GameViewController ()

@property (weak, nonatomic) IBOutlet SKView *ParticleView;

@end

@implementation GameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SKScene *particleScene = [SKScene nodeWithFileNamed:@"ParticleScene"];
    if (particleScene) {
        [self.ParticleView presentScene:particleScene];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
