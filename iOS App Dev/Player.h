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
}

- (id) initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
- (void)fly; //veit ekkert hvort eg muni thurfa thetta

@end