//
//  Collectable.h
//  iOS App Dev
//
//  Created by temp test testing 9/30/13.
//  Copyright 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Coin : CCPhysicsSprite
{
    
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;

@end
