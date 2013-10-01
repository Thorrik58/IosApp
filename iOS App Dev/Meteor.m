//
//  Meteor.m
//  iOS App Dev
//
//  Created by temp test testing on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "Meteor.h"
#import "ChipmunkAutoGeometry.h"

@implementation Meteor
- (id) initWithSpace:(ChipmunkSpace *)space position:(CGPoint)position;
{
    self = [super initWithFile:@"meteor.png"];
    if (self)
    {
        if (space != nil)
        {
            //Config file loaded
            NSDictionary *configuration = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Configuration" ofType:@"plist"]];
            
            //To fix the offset of the image within the auto-geometry.
            CCSprite *sprite = [CCSprite spriteWithFile:@"meteor.png"];
            CGPoint anchor = cpvadd(sprite.anchorPointInPoints, cpvzero);
            sprite.anchorPoint = ccp(anchor.x/sprite.contentSize.width, anchor.y/sprite.contentSize.height);
            
            
            NSURL *url = [[NSBundle mainBundle] URLForResource:@"meteor" withExtension:@"png"];
            
            ChipmunkBitmapSampler *sampler = [ChipmunkImageSampler samplerWithImageFile:url isMask:NO];
            [sampler setBorderValue:0.0f];
            ChipmunkPolylineSet *lines = [sampler marchAllWithBorder:YES hard:NO];
            ChipmunkPolyline *line = [lines lineAtIndex:0];
            
            CGFloat mass = [configuration [@"meteorMass"] floatValue];
            CGFloat moment = [line momentForMass:mass offset:cpvneg(sprite.anchorPointInPoints)];
            ChipmunkBody *body = [ChipmunkBody bodyWithMass:mass andMoment:moment];
            body.pos = position;
            
            CGFloat gravity = [configuration [@"gravity"] floatValue];
            body.force = cpv(0.0f, gravity*mass);

            ChipmunkPolyline *hull = [[line simplifyCurves:1.0f] toConvexHull:1.0f];
            ChipmunkShape *shape = [hull asChipmunkPolyShapeWithBody: body offset:cpvneg(sprite.anchorPointInPoints)];
            
            [space addBody: body];
            [space addShape: shape];
            
            self.chipmunkBody = body;
            //Set lateral force.
            NSString *vectorArgument = configuration[@"lateralForce"];
            [self.chipmunkBody applyForce:cpvmult(CGPointFromString(vectorArgument), -10.0f) offset:cpvzero];
        }
    }
    return self;
}

@end
