//
//  Dynamite.h
//  iOS App Dev
//
//  Created by temp test testing on 10/1/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Dynamite : CCPhysicsSprite {
    
}

- (id)initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;

@end