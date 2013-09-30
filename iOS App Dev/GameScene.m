//
//  Game.m
//  IosApp Dev
//
//

#import "GameScene.h"
#import "Collectable.h"
#import "Player.h"
#import "InputLayer.h"
#import "ChipmunkAutoGeometry.h"
#import "CCParallaxNode-Extras.h"
#import "SimpleAudioEngine.h"




@implementation GameScene

#pragma mark - Initilization


//HUD and restart
+ (id)scene {
    CCScene *scene = [CCScene node];
    
    GameScene *layer = [GameScene node];
    [scene addChild:layer];
    
    return scene;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        srandom(time(NULL));
        
        
        _hudLayer = [[HUDLayer alloc] init];
        [self addChild:_hudLayer z:1];
        
        //Config file loaded
        _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
        
        //Window size
        _winSize = [CCDirector sharedDirector].winSize;
        
        //Create physics world.
        _space = [[ChipmunkSpace alloc] init];
        CGFloat gravity = [_configuration [@"gravity"] floatValue];
        _space.gravity = ccp(0.0f, -gravity);
        
        NSMutableArray *coinsArray = [[NSMutableArray alloc] init];
        _coinsArray = coinsArray;
        
        //Background set up
        [self setupGraphicsWorld];
        [self setupPhysicsWorld];
        
        //Create debug node
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debugNode.visible = YES;
        [self addChild:debugNode];
        
        //Player character set up with starting position
        NSString *playerPositionString = _configuration[@"playerStartingPos"];
        
        // Register collision handler
        [_space setDefaultCollisionHandler:self
                                     begin:@selector(collisionBegan:space:)
                                     preSolve:nil
                                     postSolve:nil
                                     separate:nil];

        _player = [[Player alloc] initWithSpace:_space position:CGPointFromString(playerPositionString)];
        [_gameNode addChild:_player];
        
        for (NSUInteger i = 0; i < 10; ++i)
        {
            [self createCoin];
        }
        
        
        
        /*_coin = [[Collectable alloc] initWithSpace:_space position:CGPointFromString(_configuration[@"coinPosition"])];
        [_gameNode addChild:_coin];*/
        
        
        // Create a input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        // Your initilization code goes here
        [self scheduleUpdate];

    }
    return self;
}

- (void) setupPhysicsWorld
{
    /*
     First approach. Auto Geometry used to get the all the lines of the grass.*/
    NSURL *floorUrl = [[NSBundle mainBundle] URLForResource:@"cloudl" withExtension:@"png"];
    ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:floorUrl isMask:NO];
    
    ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *line = [contour lineAtIndex:0];
    ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
    
    //ChipmunkBody *floorBody = [ChipmunkBody bodyWithMass:1000000000.0f andMoment:INFINITY];
    //CGFloat gravity = [_configuration [@"gravity"] floatValue];
    //floorBody.force = cpv(0.0f, gravity*1000000000);
    ChipmunkBody *floorBody = [ChipmunkBody staticBody];
    NSArray *floorShapes = [simpleLine asChipmunkSegmentsWithBody:floorBody radius:0 offset:cpv(0.0f, _winSize.height*0.83)];
    for (ChipmunkShape *shape in floorShapes)
    {
        [_space addShape:shape];
    }
    
    
     
    //The second approach. A simple rectangle in the middle of the grass.
    //Now it appears as though you land in the middle of the grass.
    CCSprite* landscape = [CCSprite spriteWithFile:@"small-grassl.png"];
    CGSize size = landscape.textureRect.size;
    ChipmunkBody *body = [ChipmunkBody staticBody];
    body.pos = ccp(0, size.height/4);
    //height size has a constant because of positioning in middle of grass
    ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height/8];
    [_space addShape:shape];
}


- (void)setupGraphicsWorld
{
    
    //Skylayer set up with gradient orange to blue
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(0, 48, 150, 255) fadingTo:ccc4(242, 155, 5, 255)];
    [self addChild:_skyLayer];
    [_backgroundNode addChild:_skyLayer z:0 parallaxRatio:ccp(0.0f,0.0f) positionOffset:CGPointZero];
    
    //ParallaxEffect
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode];
    
    //Speed which objects move in background
    CGPoint grassSpeed = ccp(1.0, 1.0);
    CGPoint landscapeSpeed = ccp(0.05, 0.05);
    CGPoint moonSpeed = ccp(0.005, 0.005);
    
    //trees
    CCSprite* trees = [CCSprite spriteWithFile:@"tree2.png"];
    trees.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:trees z:1 parallaxRatio:landscapeSpeed positionOffset:ccp(600,_winSize.height * 0)];
    
    //moon
    CCSprite* moon = [CCSprite spriteWithFile:@"moon.png"];
    moon.anchorPoint = ccp(0, 0);
    [_backgroundNode addChild:moon z:-1 parallaxRatio:moonSpeed positionOffset:ccp(500,_winSize.height * 0.6)];

    //Ceiling
    _ceiling = [CCSprite spriteWithFile:@"cloudl.png"];
    _ceiling.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:_ceiling z:-1 parallaxRatio:grassSpeed positionOffset:ccp(0,_winSize.height*0.83)];
    
    _ceiling2 = [CCSprite spriteWithFile:@"cloudl.png"];
    _ceiling2.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:_ceiling2 z:-1 parallaxRatio:grassSpeed positionOffset:ccp(2000,_winSize.height*0.83)];
    _lastAppendPos = _ceiling2.position.x + _ceiling2.contentSize.width;
    
    
    //grass
    CCSprite* landscape = [CCSprite spriteWithFile:@"small-grassl.png"];
    landscape.anchorPoint = ccp(0,0);
    _landscapeWidth = landscape.contentSize.width;
    [_backgroundNode addChild:landscape z:2 parallaxRatio:grassSpeed positionOffset:CGPointZero];
    _floor = landscape;
    
    _gameNode = [CCNode node];
    [_backgroundNode addChild:_gameNode z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
}


#pragma mark - Update

- (void)update:(ccTime)delta
{
    CGFloat fixedTimeStep = 1.0f / 240.0f;
    _accumulator += delta;
    while (_accumulator > fixedTimeStep)
    {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }

    //Distance travelled, we start at startingPosX so thats deducted
    CGFloat startPosX = [_configuration[@"startingPosX"] floatValue];

    _distanceScore = (_player.position.x - startPosX)/100;
    
    [_hudLayer setScoreString:[NSString stringWithFormat:@"Score: %.0f", _distanceScore]];
    
    //cpVect vect = cpv(1000.0f, 0.0f);
    //[_player.chipmunkBody applyForce:vect offset:cpvzero];
    

    if (_player.position.x >= (_winSize.width /2))
    {
        _backgroundNode.position = ccp(-(_player.position.x - (_winSize.width / 2)),0);
    }
    
    /*if (_player.position.x > _lastAppendPos/2)
    {
        [self extendTunnel];
    }*/
    
       
    
    //NSLog(@"Pos: %f",_distanceScore);
    
    
    
    
    NSArray *ceilings = [NSArray arrayWithObjects:_ceiling,_ceiling2, nil];
    for (CCSprite *ceiling in ceilings) {
        if ([_backgroundNode convertToWorldSpace:ceiling.position].x < -ceiling.contentSize.width) {
            [_backgroundNode incrementOffset:ccp(2*ceiling.contentSize.width,0) forChild:ceiling];
        }
    }
}

#pragma mark - My Touch Delegate Methods
- (void)touchBegan
{
    NSLog(@"touch began!!");
    [_player jumpWithForceVector];
}

- (void)touchEnded
{
    NSLog(@"touch ended!");
    [_player removeUpwardForce];    
}

#pragma mark - Collision methods
- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    
    for (Collectable* coin in _coinsArray)
    {
        if ((firstChipmunkBody == _player.chipmunkBody && secondChipmunkBody == coin.chipmunkBody) ||
            (firstChipmunkBody == coin.chipmunkBody && secondChipmunkBody == _player.chipmunkBody))
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            
            /*[_space smartRemove:coin.chipmunkBody];
            for (ChipmunkShape *shape in coin.chipmunkBody.shapes) {
                [_space smartRemove:shape];
            }
            [coin removeFromParentAndCleanup:YES];*/
        }
    }
    
    
        return YES;
}

- (void)extendTunnel
{
    CGPoint grassSpeed = ccp(1.0, 1.0);
    if (_ceiling.position.x > _ceiling2.position.x)
    {
        NSLog(@"OMG TRUE RELOCATE!!!!!!");
        NSLog(@"_ceiling.position.x %f",_lastAppendPos);
        
        [_backgroundNode removeChild: _ceiling2 cleanup:YES ];
        _ceiling2 = [CCSprite spriteWithFile:@"cloudl.png"];
        _ceiling2.anchorPoint = ccp(0,0);
        [_backgroundNode addChild:_ceiling2 z:-1 parallaxRatio:grassSpeed positionOffset:ccp(_lastAppendPos,_winSize.height*0.83)];
        _lastAppendPos = _ceiling2.position.x + _ceiling2.contentSize.width;
    }
    else
    {
        NSLog(@"OMG2 TRUE RELOCATE!!!!!!");
        NSLog(@"_ceiling.position.x %f",_lastAppendPos);
        NSLog(@"_player.position.x %f",_player.position.x);

        [_backgroundNode removeChild: _ceiling cleanup:YES ];
        _ceiling = [CCSprite spriteWithFile:@"cloudl.png"];
        _ceiling.anchorPoint = ccp(0,0);
        [_backgroundNode addChild:_ceiling z:-1 parallaxRatio:grassSpeed positionOffset:ccp(_lastAppendPos,_winSize.height*0.83)];
        _lastAppendPos = _ceiling.position.x + _ceiling.contentSize.width;
    }
    
    
    
    
    //Ceiling
    _ceiling = [CCSprite spriteWithFile:@"cloudl.png"];
    _ceiling.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:_ceiling z:-1 parallaxRatio:grassSpeed positionOffset:ccp(0,_winSize.height*0.83)];
    
    
}

-(void)createCoin{
    
    int randomNumberx = [self getRandomNumberBetween:200 to:4000];
    int randomNumbery = [self getRandomNumberBetween:20 to:_winSize.height-20];
    // Add coin
    Collectable *bla = [[Collectable alloc] initWithSpace:_space position:ccp(randomNumberx,randomNumbery)];
    [_gameNode addChild:bla];    
    [_coinsArray addObject:bla];
    
    
    /*
    for (NSUInteger i = 0; i < 4; ++i)
    {
        Collectable *coin = [Collectable alloc];
        cloud.position = ccp(CCRANDOM_0_1() * _winSize.width, (CCRANDOM_0_1() * 200) + _winSize.height / 2);
        [_skyLayer addChild:cloud];
    }*/
}

-(int)getRandomNumberBetween:(int)from to:(int)to {
    return (int)from + arc4random() % (to-from+1);
}


@end
