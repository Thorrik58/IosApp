//
//  Game.m
//  IosApp Dev
//
//

#import "GameScene.h"
#import "Player.h"
#import "InputLayer.h"





@implementation GameScene

#pragma mark - Initilization

- (id)init
{
    self = [super init];
    if (self)
    {
        srandom(time(NULL));
        
        //Config file loaded
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
        
        //Window size
        _winSize = [CCDirector sharedDirector].winSize;
        
        //not used really
        [self generateRandomWind];
        
        //Background set up
        [self setupGraphicsLandscape];
        
        //Player character set up with starting position
        NSString *playerPositionString = _configuration[@"playerStartingPos"];
        _player = [[Player alloc] initWithPosition:CGPointFromString(playerPositionString)];
        [_gameNode addChild:_player];
        
        // Create a input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        // Your initilization code goes here
        [self scheduleUpdate];

    }
    return self;
}

- (void)setupGraphicsLandscape
{
    
    //Skylayer set up with gradient orange to blue
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(0, 48, 150, 255) fadingTo:ccc4(242, 155, 5, 255)];
    [self addChild:_skyLayer];
    
    //ParallaxEffect
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode z:1];
    
    //Speed which objects move in background
    CGPoint grassSpeed = ccp(0.1, 0.1);
    CGPoint landscapeSpeed = ccp(0.05, 0.05);
    CGPoint moonSpeed = ccp(0.0005, 0.0005);
    
    //trees
    CCSprite* trees = [CCSprite spriteWithFile:@"tree2.png"];
    trees.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:trees z:-1 parallaxRatio:landscapeSpeed positionOffset:ccp(600,_winSize.height * 0)];
    
    //moon
    CCSprite* moon = [CCSprite spriteWithFile:@"moon.png"];
    moon.anchorPoint = ccp(0, 0);
    [_backgroundNode addChild:moon z:-1 parallaxRatio:moonSpeed positionOffset:ccp(_winSize.width,_winSize.height * 0.6)];

    //Ceiling
    CCSprite* ceiling = [CCSprite spriteWithFile:@"thorns.png"];
    ceiling.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:ceiling z:-1 parallaxRatio:grassSpeed positionOffset:ccp(0,_winSize.height*0.9)];

    
    //grass
    CCSprite* landscape = [CCSprite spriteWithFile:@"grass-small.png"];
    landscape.anchorPoint = ccp(0,0);
    _landscapeWidth = landscape.contentSize.width;
    [_backgroundNode addChild:landscape z:-1 parallaxRatio:grassSpeed positionOffset:CGPointZero];
    
    _gameNode = [CCNode node];
    [_backgroundNode addChild:_gameNode z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];

    
    
}


#pragma mark - Update

- (void)update:(ccTime)delta
{
    
    //CGPoint backgroundScrollVel = ccp(-1000, 0);
    //_backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, delta));
    
    if (_player.position.x >= (_winSize.width / 2) && _player.position.x < (_landscapeWidth - (_winSize.width / 2)))
    {
        _backgroundNode.position = ccp(-(_player.position.x - (_winSize.width / 2)), 0);
    }
}

#pragma mark - My Touch Delegate Methods

- (void)touchEnded
{
    //Yet to be implemented properly
    [_player fly];    
}



- (void)generateRandomWind
{
    //not used 
   _windSpeed = CCRANDOM_MINUS1_1() * [_configuration[@"windMaxSpeed"] floatValue];
}



@end
