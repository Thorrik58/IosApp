//
//  Player.h
//  iOS App Dev
//
//  Created by Þorvarður on 9/24/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCPhysicsSprite
{
    ChipmunkSpace *_space;
    NSDictionary *_configuration;
}


- (id) initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
- (void)jumpWithForceVector;
- (void)applyImpulseOnExplosion:(CGFloat)impulse vector:(cpVect)normalizedVector;
- (void)removeUpwardForce;
- (void)lateralForce;
@end