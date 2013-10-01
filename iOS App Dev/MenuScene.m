//
//  MenuScene.m
//  iOS App Dev
//
//  Created by temp test testing on 9/26/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "MenuScene.h"
#import "cocos2d.h"
#import "GameScene.h"
#import "ScoreScene.h"
#import "HUDLayer.h"

@implementation MenuScene

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"START GAME" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *start = [CCMenuItemLabel itemWithLabel:startLabel block:^(id sender)
        {
            GameScene *gameScene = [[GameScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameScene];
        }];
        CCLabelTTF *scoreLabel = [CCLabelTTF labelWithString:@"HIGH SCORE" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *score = [CCMenuItemLabel itemWithLabel:scoreLabel block:^(id sender)
        {
            ScoreScene *scoreScene = [[ScoreScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:scoreScene];
        }];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        start.position = ccp(winSize.width/2, winSize.height/2 + start.contentSize.height/1.5);
        score.position = ccp(winSize.width / 2, start.position.y - start.contentSize.height*1.5);
        
        CCMenu *menu = [CCMenu menuWithItems:start,score, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
        

    }
    return self;
}
@end
