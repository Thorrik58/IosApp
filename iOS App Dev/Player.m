//
//  Player.m
//  iOS App Dev
//
//  Created by Þorvarður on 9/24/13.
//

#import "Player.h"

@implementation Player

- (id) initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithFile:@"pony.png"];
    if (self)
    {
        _space = space;
        
        if (space != nil)
        {
            //TODO: Look into if I should perhaps do this with auto geometry.
            
            /*        
             //Not working!!
             NSURL *url = [[NSBundle mainBundle] URLForResource:@"pony" withExtension:@"png"];
             
             ChipmunkImageSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
             ChipmunkPolylineSet *contour = [sampler marchAllWithBorder:NO hard:YES];
             ChipmunkPolyline *line = [contour lineAtIndex:0];
             ChipmunkPolyline *simpleLine = [line simplifyCurves:1];
             
             ChipmunkBody *ponyBody = [ChipmunkBody bodyWithMass:10000.0f andMoment:1000000.0f];
             NSArray *ponyShapes = [simpleLine asChipmunkSegmentsWithBody:ponyBody radius:0 offset:cpvzero];
             for (ChipmunkShape *shape in ponyShapes)
             {
             [_space addShape:shape];
             //self.chipmunkBody = ponyBody;
             }
             */
            
            CGSize size = self.textureRect.size;
            cpFloat mass = size.width * size.height;
            cpFloat moment = cpMomentForBox(mass, size.width, size.height);
            
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            body.pos = position;
            ChipmunkShape *shape = [ChipmunkPolyShape boxWithBody:body width:size.width height:size.height];
            
            //Add to space
            [_space addBody:body];
            [_space addShape:shape];
            
            //add to physics sprite
            
            self.chipmunkBody = body;
            
        }
    }
    return self;
}

- (void)fly
{
    CCJumpTo *jump = [CCJumpTo actionWithDuration:1.5f position:ccp(60, 215) height:100.0f jumps:1];
    [self runAction:jump];
}

            
@end

