//
//  ParticleScene.m
//  CapstoneProject
//
//  Created by Emily Ito Okabe on 7/17/22.
//

#import "ParticleScene.h"

@implementation ParticleScene

- (void)didMoveToView:(SKView *)view {
    [self addPhysicsBoundariesToScene];
    [self addBallAt:CGPointMake(60.0, 60.0)];
    [self addBallAt:CGPointMake(50.0, 50.0)];
}

- (void)addPhysicsBoundariesToScene {
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [physicsBody setDynamic:false];
    self.physicsBody = physicsBody;
}

- (void)addBallAt:(CGPoint)point {
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"ball"];
    ball.size = CGSizeMake(50.0, 50.0);
    SKPhysicsBody *physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:25.0 center:point];
    [physicsBody setRestitution:0.3];
    ball.physicsBody = physicsBody;
    [self addChild:ball];
}

@end
