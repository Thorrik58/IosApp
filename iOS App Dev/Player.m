//
//  Player.m
//  iOS App Dev
//
//  Created by Þorvarður on 9/24/13.
//

#import "Player.h"
#import "ChipmunkAutoGeometry.h"

@implementation Player

- (id) initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{

    self = [super initWithFile:@"kirby.png"];
    if (self)
    {
        _space = space;
        
        if (space != nil)
        {
            //Config file loaded
            _configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
            
            //To fix the offset of the image within the auto-geometry.
            CCSprite *sprite = [CCSprite spriteWithFile:@"kirby.png"];
            CGPoint anchor = cpvadd(sprite.anchorPointInPoints, cpvzero);
            sprite.anchorPoint = ccp(anchor.x/sprite.contentSize.width, anchor.y/sprite.contentSize.height);
            
            
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"kirby" withExtension:@"png"];
            
            ChipmunkBitmapSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
            [sampler setBorderValue:0.0f];
            ChipmunkPolylineSet *lines = [sampler marchAllWithBorder:YES hard:NO];
            ChipmunkPolyline *line = [lines lineAtIndex:0];
            
            CGFloat mass = [_configuration [@"characterMass"] floatValue];
            CGFloat moment = [line momentForMass:mass offset:cpvneg(sprite.anchorPointInPoints)];
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            body.pos = position;
            
            ChipmunkPolyline *hull = [[line simplifyCurves:1.0f] toConvexHull:1.0f];
            ChipmunkShape *shape = [hull asChipmunkPolyShapeWithBody: body offset:cpvneg(sprite.anchorPointInPoints)];
            [_space addBody: body];
            [_space addShape: shape];
            
            self.chipmunkBody = body;
            
            [self lateralForce];
        }
    }
    return self;
}

- (void)jumpWithForceVector
{
    //NSLog(@"inside jump with force vector");
    //CCJumpTo *jump = [CCJumpTo actionWithDuration:1.5f position:ccp(60, 215) height:100.0f jumps:1];
    //[self runAction:jump];
    
    cpVect forceVector = cpvmult(ccp(0,1), self.chipmunkBody.mass * 1000);
    
    //cpVect forceVector = cpvmult(vector, self.chipmunkBody.mass * 1000);
    [self.chipmunkBody applyForce:forceVector offset:cpvzero];
    //NSLog(@"The current force: %@",NSStringFromCGPoint(self.chipmunkBody.body->f));
}

- (void)removeUpwardForce
{
    //NSLog(@"The current force before remove: %@",NSStringFromCGPoint(self.chipmunkBody.body->f));
    //[self.chipmunkBody resetForces];
    self.chipmunkBody.body->f.y = 0;
    //NSLog(@"The current force after remove: %@",NSStringFromCGPoint(self.chipmunkBody.body->f));
}

-(void)lateralForce
{
    NSString *vectorArgument = _configuration[@"lateralForce"];
    [self.chipmunkBody applyForce:CGPointFromString(vectorArgument) offset:cpvzero];
}


@end

