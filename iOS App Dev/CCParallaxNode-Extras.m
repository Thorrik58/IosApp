//
//  CCParallaxNode-Extras.m
//  SpaceGame
//
//  Created by Ray Wenderlich on 5/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCParallaxNode-Extras.h"

@implementation CCParallaxNode(Extras)
@class CGPointObject;

-(void) incrementOffset:(CGPoint)offset forChild:(CCNode*)node 
{
	for( unsigned int i=0;i < _parallaxArray->num;i++) {
		CGPointObject *point = _parallaxArray->arr[i];
		if( [[point child] isEqual:node] ) {
			[point setOffset:ccpAdd([point offset], offset)];
            break;
		}
	}
}


/*
 First approach. Auto Geometry used to get the all the lines of the grass.
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


*/

@end
