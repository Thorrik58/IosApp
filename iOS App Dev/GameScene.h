//
//  GameScene.h
//  IosApp
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputLayer.h"

@class Player;
@interface GameScene : CCScene <InputLayerDelgate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    CGFloat _windSpeed;
    Player *_player;
    
    CCParallaxNode *_backgroundNode;
    CCNode *_gameNode;
    CGFloat _landscapeWidth;
    
}

@end
