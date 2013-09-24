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
            
@end

