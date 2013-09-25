//
//  Player.m
//  iOS App Dev
//
//  Created by Þorvarður on 9/24/13.
//

#import "Player.h"

@implementation Player

- (id)initWithPosition:(CGPoint)position
{
    self = [super initWithFile:@"pony.png"];
    if (self)
    {
        self.position = position;
    }
return self;
}

- (void)fly
{
    CCJumpTo *jump = [CCJumpTo actionWithDuration:1.5f position:ccp(60, 215) height:100.0f jumps:1];
    [self runAction:jump];
}

            
@end

