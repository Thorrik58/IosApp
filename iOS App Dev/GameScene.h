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
@class Coin;
@class Meteor;
@class Dynamite;
@interface GameScene : CCScene <InputLayerDelgate>
{
    CGSize _winSize;
    NSDictionary *_configuration;
    CCLayerGradient *_skyLayer;
    CCLayerColor *_endLayer;
    CCLayerColor *_caveLayer;
    Player *_player;
    
    ChipmunkSpace *_space;
    CCParticleSystemQuad *_collisionParticles;
    ccTime _accumulator;    
    
    CCParallaxNode *_backgroundNode;
    CCNode *_gameNode;
    CGFloat _landscapeWidth;
    CGFloat _totalscore;
    CGFloat _collectableScore;
    CGFloat _distanceScore;

    
    NSMutableArray *_coinArray;
    NSMutableArray *_meteorArray;
    NSMutableArray *_dynamiteArray;
    
    HUDLayer * _hudLayer;
    BOOL _gameOver;
    int _lives;
}
+ (id)scene;
-(int)getRandomNumberBetween:(int)from to:(int)to;



@end
