//
//  Game.h
//  IosApp
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Player;
@interface Game : CCScene
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    CGFloat _windSpeed;
    Player *_player;
}

@end
