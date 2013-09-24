//
//  Game.m
//  IosApp Dev
//
//

#import "Game.h"
#import "Player.h"




@implementation Game

- (id)init
{
    self = [super init];
    if (self)
    {
        srandom(time(NULL));
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
        
        //staerd gluggans
        _winSize = [CCDirector sharedDirector].winSize;
        [self generateRandomWind];
        [self setupGraphicsLandscape];
        
        //Player character set up with starting position
        NSString *playerPositionString = _configuration[@"playerStartingPos"];

        _player = [[Player alloc] initWithPosition:CGPointFromString(playerPositionString)];
        [self addChild:_player];
        //[_player fly];
        
        
        // Your initilization code goes here
        [self scheduleUpdate];
    }
    return self;
}

- (void)setupGraphicsLandscape
{
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(0, 48, 150, 255) fadingTo:ccc4(242, 155, 5, 255)];
    [self addChild:_skyLayer];
    
    /*
    //make 4 clouds
    for (NSUInteger i = 0; i < 4; ++i)
    {
        CCSprite *cloud = [CCSprite spriteWithFile:@"Cloud.png"];
        cloud.position = ccp(CCRANDOM_0_1() * [CCDirector sharedDirector].winSize.width, CCRANDOM_0_1() * ([CCDirector  sharedDirector].winSize.height / 2) + [CCDirector sharedDirector].winSize.height / 2);
        [_skyLayer addChild:cloud];
    }*/
    
    //trees
    CCSprite *trees = [CCSprite spriteWithFile:@"tree2.png"];
    trees.anchorPoint = ccp(-1.8, -0.1);
    [self addChild:trees];
    
    CCSprite *moon = [CCSprite spriteWithFile:@"moon.png"];
    moon.anchorPoint = ccp(1, -0.8);
    moon.position = ccp(moon.contentSize.width, moon.contentSize.height);
    
    [self addChild:moon];
    
    CCSprite *landscape = [CCSprite spriteWithFile:@"grass-small.png"];
    landscape.anchorPoint = ccp(0.2,0.2);
    //landscape.position = ccp(landscape.contentSize.width , landscape.contentSize.height);
    [self addChild:landscape];
    
}

- (void)update:(ccTime)delta
{
    // Update logic goes here
    /* Commented out clouds because we have no clouds :(
    for (CCSprite *cloud in _skyLayer.children)
    {
        CGPoint newPosition = ccp(cloud.position.x + (_windSpeed * delta), cloud.position.y);
        if (newPosition.x < -cloud.contentSize.width / 2)
        {
            newPosition.x = [CCDirector sharedDirector].winSize.width + (cloud.contentSize.width / 2);
        }
        else if (newPosition.x > ([CCDirector sharedDirector].winSize.width + cloud.contentSize.width / 2))
        {
            newPosition.x = -cloud.contentSize.width / 2;
        }
        
        cloud.position = newPosition;
    }
     */
}

- (void)generateRandomWind
{
    _windSpeed = CCRANDOM_MINUS1_1() * [_configuration[@"windMaxSpeed"] floatValue];
}


@end
