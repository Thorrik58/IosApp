//
//  Game.m
//  IosApp Dev
//
//

#import "GameScene.h"
#import "Coin.h"
#import "Player.h"
#import "Meteor.h"
#import "Dynamite.h"
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
        _gameOver = NO;
        
        _totalscore = 0;
        _collectableScore = 0;
        
        _lives = 3;
        
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
        
        _coinArray = [[NSMutableArray alloc] init];
        _meteorArray = [[NSMutableArray alloc] init];
        _dynamiteArray = [[NSMutableArray alloc] init];


        
        //Background set up
        [self setupGraphicsWorld];
        [self setupPhysicsWorld];
        [self plantItems];
        
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
        
        //Particle effect.
        _collisionParticles = [CCParticleSystemQuad particleWithFile:@"Impact.plist"];
        [_collisionParticles stopSystem];
        [_gameNode addChild:_collisionParticles];
        
        //Create the initial high score list.
        [self createInitialHighScore];
        
        // Preload sound effects
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"coin.wav"];
        
        // Create a input layer
        InputLayer *inputLayer = [[InputLayer alloc] init];
        inputLayer.delegate = self;
        [self addChild:inputLayer];
        
        [self scheduleUpdate];

    }
    return self;
}

-(void) plantItems
{
    for (NSUInteger i = 0; i < 20; ++i)
    {
        [self createCoin];
    }
    
    for (NSUInteger i = 0; i < 10; ++i)
    {
        [self createDynamite];
    }


    for (int i=1; i<28;i=i*3)
    {
    [self createMeteor:i*1000];
    }

}


- (void) setupPhysicsWorld
{
    
    [self physicsAutoGeoWithImage:@"cloudl" xAxis:0 yAxis:_winSize.height*0.83];
    [self physicsAutoGeoWithImage:@"cloudl" xAxis:2000 yAxis:_winSize.height*0.83];
    [self physicsAutoGeoWithImage:@"cloudl" xAxis:4000 yAxis:_winSize.height*0.83];
    [self physicsAutoGeoWithImage:@"cave-roof" xAxis:6000 yAxis:_winSize.height*0.83];
    [self physicsAutoGeoWithImage:@"cave-roof" xAxis:8000 yAxis:_winSize.height*0.83];
    [self physicsAutoGeoWithImage:@"cave-floor" xAxis:6000 yAxis:0];
    [self physicsAutoGeoWithImage:@"cave-floor" xAxis:8000 yAxis:0];

    
    //The second approach. A simple rectangle in the middle of the grass.
    //Now it appears as though you land in the middle of the grass.
    CCSprite* landscape = [CCSprite spriteWithFile:@"small-grassl.png"];
    CGSize size = landscape.textureRect.size;
    ChipmunkBody *body = [ChipmunkBody staticBody];
    body.pos = ccp(0, size.height/4);
    //height size has a constant because of positioning in middle of grass.
    //Seems that the offset is off, and you can't fix it on a box.
    ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width*6 height:size.height/8];
    shape.friction = 0.3f;
    [_space addShape:shape];
}

- (void)physicsAutoGeoWithImage: (NSString*)img xAxis:(CGFloat)x yAxis:(CGFloat)y
{
    NSURL *roofUrl = [[NSBundle mainBundle] URLForResource:img withExtension:@"png"];
    ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:roofUrl isMask:NO];
    
    ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *line = [contour lineAtIndex:0];
    ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
    
    ChipmunkBody *roofBody = [ChipmunkBody staticBody];
    NSArray *floorShapes = [simpleLine asChipmunkSegmentsWithBody:roofBody radius:0 offset:cpv(x,y)];
    
    for (ChipmunkShape *shape in floorShapes)
    {
        if([img isEqual:@"cloudl"]){
            shape.elasticity = 0.5f;
        }
        [_space addShape:shape];
    }
}


- (void)setupGraphicsWorld
{
    CGFloat endOfGame = [_configuration[@"endOfGame"]floatValue];
    
    _endLayer = [CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)];
    [self addChild:_endLayer];
    [_backgroundNode addChild:_endLayer z:30 parallaxRatio:ccp(0.0f,0.0f) positionOffset:CGPointZero];
    
    _caveLayer = [CCLayerColor layerWithColor:ccc4(105, 67, 44, 255)];
    [self addChild:_caveLayer];
    [_backgroundNode addChild:_caveLayer z:0 parallaxRatio:ccp(0.0f,0.0f) positionOffset:CGPointZero];
    
    //Skylayer set up with gradient orange to blue
    _skyLayer = [CCLayerGradient layerWithColor:ccc4(0, 48, 150, 255) fadingTo:ccc4(242, 155, 5, 255)];
    [self addChild:_skyLayer];
    [_backgroundNode addChild:_skyLayer z:0 parallaxRatio:ccp(0.0f,0.0f) positionOffset:CGPointZero];
    
    //ParallaxEffect
    _backgroundNode = [CCParallaxNode node];
    [self addChild:_backgroundNode];
    
    //Gamenode
    _gameNode = [CCNode node];
    [_backgroundNode addChild:_gameNode z:1 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
    
    //Speed which objects move in background
    CGPoint grassSpeed = ccp(1.0, 1.0);
    CGPoint treeSpeed = ccp(0.5, 0.5);
    CGPoint moonSpeed = ccp(0.1, 0.1);
    

    //CCSprite objects which arent member variables
    [self parallaxSprite:@"tree2.png" xAxis:600 yAxis:_winSize.height*0 Speed:treeSpeed zIndex:0];
    [self parallaxSprite:@"moon.png" xAxis:500 yAxis:_winSize.height*0.6 Speed:moonSpeed zIndex:-1];
    [self parallaxSprite:@"cloudl.png" xAxis:0 yAxis:_winSize.height*0.83 Speed:grassSpeed zIndex:-1];
    [self parallaxSprite:@"cloudl.png" xAxis:2000 yAxis:_winSize.height*0.83 Speed:grassSpeed zIndex:-1];
    [self parallaxSprite:@"cloudl.png" xAxis:4000 yAxis:_winSize.height*0.83 Speed:grassSpeed zIndex:-1];
    [self parallaxSprite:@"cave-roof.png" xAxis:6000 yAxis:_winSize.height*0.83 Speed:grassSpeed zIndex:-1];
    [self parallaxSprite:@"cave-roof.png" xAxis:8000 yAxis:_winSize.height*0.83 Speed:grassSpeed zIndex:-1];
    [self parallaxSprite:@"small-grassl.png" xAxis:0 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"small-grassl.png" xAxis:2000 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"small-grassl.png" xAxis:4000 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"cave-floor.png" xAxis:6000 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"cave-floor.png" xAxis:8000 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"endWall.png" xAxis:10000 yAxis:_winSize.height*0 Speed:grassSpeed zIndex:2];
    [self parallaxSprite:@"flag.png" xAxis:endOfGame yAxis:_winSize.height*0.15 Speed:grassSpeed zIndex:3];

}

- (void)parallaxSprite: (NSString*) img xAxis:(CGFloat)x yAxis:(CGFloat)y Speed:(CGPoint)s zIndex:(int)z
{
    CCSprite* object = [CCSprite spriteWithFile:img];
    object.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:object z:z parallaxRatio:s positionOffset:ccp(x,y)];
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
    CGFloat distanceScore = (_player.position.x - startPosX)/100;
    if (!_gameOver)
    {
        _totalscore = distanceScore + _collectableScore;
    }
    
    
    [_hudLayer setScoreString:[NSString stringWithFormat:@"Score: %.0f", _totalscore]];
    
    [_hudLayer setStatusString:[NSString stringWithFormat:@"Lives: %d", _lives]];
    
    [self statusOfGame];
}

-(void)statusOfGame
{
    CGFloat endOfGame = [_configuration[@"endOfGame"]floatValue];

    if (_player.position.x >= (_winSize.width /2))
    {
        _backgroundNode.position = ccp(-(_player.position.x - (_winSize.width / 2)),0);
    }
    
    if (_player.position.x >= 6000)
    {
        _skyLayer.visible = NO;
    }
    
    if (_player.position.x > endOfGame && _gameOver == NO)
    {
        _caveLayer.visible = NO;
        [self gameOver:YES];
        _gameOver = YES;
    }
    if (_lives<=0 && _gameOver == NO)
    {
        //[_hudLayer showRestartMenu:NO];
        [self gameOver:NO];
        _gameOver = YES;
        _player.visible = NO;
    }
    if(_player.position.x < 0 && _gameOver == NO)
    {
        [self gameOver:NO];
        _gameOver = YES;
    }
    //NSLog(@"Pos: %f",_distanceScore);
}

#pragma mark - My Touch Delegate Methods
- (void)touchBegan
{
    [_player jumpWithForceVector];
}

- (void)touchEnded
{
    [_player removeUpwardForce];
}

#pragma mark - Collision methods
- (bool)collisionBegan:(cpArbiter *)arbiter space:(ChipmunkSpace*)space
{
    Coin* removedCoin;
    Dynamite* removedDyna;


    for (Meteor* meteor in _meteorArray)
    {
        if([self areBodiesColliding:arbiter firstSprite:_player secondSprite:meteor])
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"bonk.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            if(_lives != 0){
                _lives = _lives -1;
            }
        
            //Play the particle effect.
            _collisionParticles.position = _player.position;
            [_collisionParticles resetSystem];
        }
    }
    
    for (Coin* coin in _coinArray)
    {
        if([self areBodiesColliding:arbiter firstSprite:_player secondSprite:coin])
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"coin.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            
            _collectableScore = _collectableScore +10;
            
            for (ChipmunkShape *shape in coin.chipmunkBody.shapes) {
                [_space smartRemove:shape];
                
            }
            [coin removeFromParentAndCleanup:YES];
            removedCoin = coin;
        }
    }
    
    //To remove the coin from the coin array.
    if (removedCoin != nil)
    {
        [_coinArray removeObject:removedCoin];
    }
    
    for (Dynamite* dyna in _dynamiteArray)
    {
        if([self areBodiesColliding:arbiter firstSprite:_player secondSprite:dyna])
        {
            [[SimpleAudioEngine sharedEngine] playEffect:@"bomb.wav" pitch:(CCRANDOM_0_1() * 0.3f) + 1 pan:0 gain:1];
            cpVect normalizedVector = cpvnormalize(cpvsub(_player.position, _dynamite.position));
            CGFloat impulse = [_configuration [@"impulseFromExplosion"] floatValue];
            [_player applyImpulseOnExplosion:impulse vector:normalizedVector];
            
            //Lose a live if you hit a dynamite.
            if(_lives != 0){
                _lives = _lives -1;
            }
            
            //Play the particle effect.
            _collisionParticles.position = _player.position;
            [_collisionParticles resetSystem];
                        
            //[_space smartRemove:coin.chipmunkBody];
            for (ChipmunkShape *shape in dyna.chipmunkBody.shapes) {
                [_space smartRemove:shape];
                
            }
            [dyna removeFromParentAndCleanup:YES];
            removedDyna = dyna;
        }
    }
    
    //To remove the coin from the coin array.
    if (removedDyna != nil)
    {
        [_dynamiteArray removeObject:removedDyna];
    }
    return YES;
}



//Checks if the two provided sprites are colliding.
- (BOOL) areBodiesColliding:(cpArbiter*) arbiter firstSprite:(CCPhysicsSprite*) first secondSprite:(CCPhysicsSprite*) second
{
    cpBody *firstBody;
    cpBody *secondBody;
    cpArbiterGetBodies(arbiter, &firstBody, &secondBody);
    
    ChipmunkBody *firstChipmunkBody = firstBody->data;
    ChipmunkBody *secondChipmunkBody = secondBody->data;
    
    if ((firstChipmunkBody == first.chipmunkBody && secondChipmunkBody == second.chipmunkBody) ||
        (firstChipmunkBody == second.chipmunkBody && secondChipmunkBody == first.chipmunkBody))
    {
        return YES;
    }
    return NO;
}

-(void)createCoin{
    
    int randomNumberx = [self getRandomNumberBetween:200 to:10000];
    int randomNumbery;
    
    //Check if coin is appearing within the cave or not, then we need to readjust the y axis
    if (randomNumberx >= 6000)
    {
        randomNumbery = [self getRandomNumberBetween:40 to:_winSize.height-100];
    }
    else
    {
        randomNumbery = [self getRandomNumberBetween:40 to:_winSize.height-80];
    }
    
    // Add coin
    Coin *coin = [[Coin alloc] initWithSpace:_space position:ccp(randomNumberx,randomNumbery)];
    [_gameNode addChild:coin];
    [_coinArray addObject:coin];
}

-(void)createDynamite
{
    int randomNumberx = [self getRandomNumberBetween:200 to:10000];
    int randomNumbery = [self getRandomNumberBetween:40 to:50];
    // Add Dynamite
    Dynamite *dynamite = [[Dynamite alloc] initWithSpace:_space position:ccp(randomNumberx,randomNumbery)];
    [_gameNode addChild:dynamite];
    [_dynamiteArray addObject:dynamite];
}

-(void)createMeteor:(CGFloat)x
{
    int randomNumbery;
    if (x >= 6000)
    {
        randomNumbery = [self getRandomNumberBetween:40 to:_winSize.height-100];
    }
    else
    {
        randomNumbery = [self getRandomNumberBetween:40 to:_winSize.height-80];
    }
    // Add Meteor
    Meteor *meteor = [[Meteor alloc] initWithSpace:_space position:ccp(x,randomNumbery)];
    [_gameNode addChild:meteor];
    [_meteorArray addObject:meteor];
}

-(int)getRandomNumberBetween:(int)from to:(int)to
{
    return (int)from + arc4random() % (to-from+1);
}

- (void)gameOver:(BOOL)win
{
	// Show "game over" text
    //[_hudLayer showRestartMenu:win];

  	// Get high scores array from "defaults" object
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSMutableArray *highScores = [NSMutableArray arrayWithArray:[defaults arrayForKey:@"highScore"]];
	
    NSInteger newHighScore = 0;
	// Check if the current score made it to the  high socre list.
	for (int i = 0; i < [highScores count]; i++)
	{
		if (_totalscore >= [[highScores objectAtIndex:i] intValue])
		{
			// Insert new high score, which pushes all others down
			[highScores insertObject:[NSNumber numberWithInt:_totalscore] atIndex:i];
			
			// Remove last score, so as to ensure only 5 entries in the high score array
			[highScores removeLastObject];
			
			// Re-save scores array to user defaults
			[defaults setObject:highScores forKey:@"highScore"];
			
			[defaults synchronize];
			
            newHighScore = 1;
			NSLog(@"Saved new high score of %f", _totalscore);
			
			// Bust out of the loop
			break;
		}
	}
    if( newHighScore ){
        [_hudLayer showRestartMenu:win highScore:YES];
    }
    else{
        [_hudLayer showRestartMenu:win highScore:NO];
    }
}

-(void) createInitialHighScore
{
    
     NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
     
     // Register default high scores. Can't get it to work by using a plist.
     NSDictionary *defaultDefaults = [NSDictionary dictionaryWithObject:[NSArray arrayWithObjects:[NSNumber numberWithInt:0],
                                                                         [NSNumber numberWithInt:0],
                                                                         [NSNumber numberWithInt:0],
                                                                         [NSNumber numberWithInt:0],
                                                                         [NSNumber numberWithInt:0],
                                                                         nil]
                                                                 forKey:@"highScore"];
    
        [defaults registerDefaults:defaultDefaults];
    [defaults synchronize];
}

@end
