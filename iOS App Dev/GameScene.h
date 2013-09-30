//
//  GameScene.h
//  IosApp
//
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "InputLayer.h"
#import "HUDLayer.h"


@class Player;
@class Collectable;
@interface GameScene : CCScene <InputLayerDelgate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    Player *_player;
    Collectable *_coin;
    
    ChipmunkSpace *_space;
    ccTime _accumulator;    
    
    CCParallaxNode *_backgroundNode;
    CCNode *_gameNode;
    CGFloat _landscapeWidth;
    CGFloat _distanceScore;
    
    
    //layers needed to readjust in run
    CCSprite *_ceiling;
    CCSprite *_ceiling2;
    CCSprite *_floor;
    CCSprite *_floor2;
    
    HUDLayer * _hudLayer;
    
    CGFloat _lastAppendPos;
}
+ (id)scene;
-(int)getRandomNumberBetween:(int)from to:(int)to;



@end
