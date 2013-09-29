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


//HUD and restart
+ (id)scene {
    CCScene *scene = [CCScene node];
    
    GameScene *layer = [GameScene node];
    [scene addChild:layer];
    
    return scene;
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [GameScene scene];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:scene]];
    
}

- (void)showRestartMenu:(BOOL)won {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (won) {
        message = @"You win!";
    } else {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial-hd.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial-hd.fnt"];
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

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
        
        //TODO: Z INDEX FIXES!
        //Score label set up to keep track of score
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial-hd.fnt"];
        } else {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial.fnt"];
        }
        _scoreLabel.position = ccp(_winSize.width* 0.2, _winSize.height * 0.9);
        [self addChild:_scoreLabel z:10];
        
        
        // Your initilization code goes here
        [self scheduleUpdate];

    }
    return self;
}


- (void)setScoreString:(NSString *)string {
    _scoreLabel.string = string;
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
    _ceiling = ceiling;
    
    CCSprite* ceiling2 = [CCSprite spriteWithFile:@"cloudl.png"];
    ceiling2.anchorPoint = ccp(0,0);
    [_backgroundNode addChild:ceiling2 z:-1 parallaxRatio:grassSpeed positionOffset:ccp(2000,_winSize.height*0.83)];
    _lastAppendPos = ceiling2.position.x + ceiling2.contentSize.width;
    _ceiling2 = ceiling2;
    
    
    //grass
    CCSprite* landscape = [CCSprite spriteWithFile:@"small-grassl.png"];
    landscape.anchorPoint = ccp(0,0);
    _landscapeWidth = landscape.contentSize.width;
    [_backgroundNode addChild:landscape z:-1 parallaxRatio:grassSpeed positionOffset:CGPointZero];
    _floor = landscape;
    
    _gameNode = [CCNode node];
    [_backgroundNode addChild:_gameNode z:2 parallaxRatio:ccp(1.0f, 1.0f) positionOffset:CGPointZero];
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
    
    [self setScoreString:[NSString stringWithFormat:@"Score: %.0f", _distanceScore]];
        
    if (_player.position.x >= (_winSize.width /2))
    {
        _backgroundNode.position = ccp(-(_player.position.x - (_winSize.width / 2)),0);
    }
    
       
    
    //NSLog(@"Pos: %f",_distanceScore);

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

/*- (void)extendTunnel
{
    if (_ceiling.position.x > _ceiling2.position.x)
    {
        _ceiling2.position.x = ccp(_lastAppendPos, _ceiling2.position.y);
        _floor2.position.x = _lastAppendPos;
        _lastAppendPos = _floor2.position.x + _floor2.contentSize.width;
    }
    else
    {
        _ceiling.position.x = _lastAppendPos;
        _floor.position.x = _lastAppendPos;
        _lastAppendPos = _floor.position.x + _floor.contentSize.width;

    }
}*/


@end
