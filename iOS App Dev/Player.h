//
//  Player.h
//  iOS App Dev
//
//  Created by Þorvarður on 9/24/13.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Player : CCSprite
{
    
}

- (id)initWithPosition:(CGPoint)position;
- (void)fly; //veit ekkert hvort eg muni thurfa thetta

@end