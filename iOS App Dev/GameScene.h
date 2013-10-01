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
    CCLayerColor *_endLayer;
    CCLayerColor *_caveLayer;
    Player *_player;
    Collectable *_coin;
    
    ChipmunkSpace *_space;
    ccTime _accumulator;    
    
    CCParallaxNode *_backgroundNode;
    CCNode *_gameNode;
    CGFloat _landscapeWidth;
    CGFloat _distanceScore;
    
    NSMutableArray *_coinsArray;
    
    HUDLayer * _hudLayer;
    
    CGFloat _lastAppendPos;
    
    BOOL _gameWon;
}
+ (id)scene;
-(int)getRandomNumberBetween:(int)from to:(int)to;



@end
