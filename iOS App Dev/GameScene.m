//
//  Game.m
//  IosApp Dev
//
//

#import "GameScene.h"
#import "Player.h"
#import "InputLayer.h"
#import "ChipmunkAutoGeometry.h"





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
        
        //Create physics world.
        _space = [[ChipmunkSpace alloc] init];
        CGFloat gravity = [_configuration [@"gravity"] floatValue];
        _space.gravity = ccp(0.0f, -gravity);
        
        //Background set up
        [self setupGraphicsWorld];
        [self setupPhysicsWorld];
        
        //Create debug node
        CCPhysicsDebugNode *debugNode = [CCPhysicsDebugNode debugNodeForChipmunkSpace:_space];
        debugNode.visible = YES;
        [self addChild:debugNode];
        
        //Player character set up with starting position
        NSString *playerPositionString = _configuration[@"playerStartingPos"];

        _player = [[Player alloc] initWithSpace:_space position:CGPointFromString(playerPositionString)];
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


- (void) setupPhysicsWorld
{
    /*
     First approach. Auto Geometry used to get the all the lines of the grass.*/
    NSURL *floorUrl = [[NSBundle mainBundle] URLForResource:@"cloud" withExtension:@"png"];
    ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:floorUrl isMask:NO];
    
    ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
    ChipmunkPolyline *line = [contour lineAtIndex:0];
    ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
    
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
    [self addChild:_backgroundNode z:1];
    
    //Speed which objects move in background
    CGPoint grassSpeed = ccp(1.0, 1.0);
    CGPoint landscapeSpeed = ccp(0.05, 0.05);
    CGPoint moonSpeed = ccp(0.005, 0.005);
    
    //trees
    CCSprite* trees = [CCSprite spriteWithFile:@"tree2.png"];
    trees.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:trees z:-1 parallaxRatio:landscapeSpeed positionOffset:ccp(600,_winSize.height * 0)];
    
    //moon
    CCSprite* moon = [CCSprite spriteWithFile:@"moon.png"];
    moon.anchorPoint = ccp(0, 0);
    [_backgroundNode addChild:moon z:-1 parallaxRatio:moonSpeed positionOffset:ccp(500,_winSize.height * 0.6)];

    //Ceiling
    CCSprite* ceiling = [CCSprite spriteWithFile:@"cloudl.png"];
    ceiling.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:ceiling z:-1 parallaxRatio:grassSpeed positionOffset:ccp(0,_winSize.height*0.83)];

    
    //grass
    CCSprite* landscape = [CCSprite spriteWithFile:@"small-grassl.png"];
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
    CGFloat fixedTimeStep = 1.0f / 240.0f;
    _accumulator += delta;
    while (_accumulator > fixedTimeStep)
    {
        [_space step:fixedTimeStep];
        _accumulator -= fixedTimeStep;
    }
    
    cpVect vect = cpv(1000.0f, 0.0f);
    [_player.chipmunkBody applyForce:vect offset:cpvzero];
    
    if (_player.position.x >= (_winSize.width /2))
    {
        //CGPoint backgroundScrollVel = ccp(-1000, 0);
        //_backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, delta));
        _backgroundNode.position = ccp(-(_player.position.x - (_winSize.width / 2)),0);
        
    
    }
}

#pragma mark - My Touch Delegate Methods
- (void)touchBegan
{
    NSLog(@"touch began!!");
    //[_player flyWithForce];
    //float force = [_configuration[@"forceVector"] floatValue];
    //cpVect vector = cpv(0.0f, force);
    //[_player jumpWithForceVector:cpvnormalize(vector)];
    [_player jumpWithForceVector];
}

- (void)touchEnded
{
    NSLog(@"touch ended!");
    [_player removeForces];
    
}


@end
