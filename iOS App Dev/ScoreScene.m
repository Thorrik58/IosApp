//
//  ScoreScene.m
//  iOS App Dev
//
//  Created by temp test testing on 9/30/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "ScoreScene.h"
#import "cocos2d.h"
#import "MenuScene.h"
#import "GameScene.h"
#import "HUDLayer.h"

@implementation ScoreScene
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        /*
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"START GAME" fontName:@"Arial" fontSize:48];
        CCMenuItemLabel *start = [CCMenuItemLabel itemWithLabel:label block:^(id sender)
        {
            GameScene *gameScene = [[GameScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:gameScene];
        }];
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        start.position = ccp(winSize.width/2, winSize.height/2);
        
        CCMenu *menu = [CCMenu menuWithItems:start, nil];
        menu.position = CGPointZero;
        [self addChild:menu];
         */
        
        // Get window size
        CGSize winSize = [CCDirector sharedDirector].winSize;
        
        // Get scores array stored in user defaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        // Get high scores array from "defaults" object
        NSArray *highScores = [defaults arrayForKey:@"highScore"];
        
        // Create title label
        CCLabelTTF *title = [CCLabelTTF labelWithString:@"High Scores" fontName:@"Courier" fontSize:32.0];
        [title setPosition:ccp(winSize.width / 2, winSize.height - title.contentSize.height)];
        [self addChild:title];
        
        // Create a mutable string which will be used to store the score list
        NSMutableString *scoresString = [NSMutableString stringWithString:@""];
        
        // Iterate through array and print out high scores
        for (int i = 0; i < [highScores count]; i++)
        {
            [scoresString appendFormat:@"%i. %i\n", i + 1, [[highScores objectAtIndex:i] intValue]];
        }
        
        // Create label that will display the scores - manually set the dimensions due to multi-line content
        CCLabelTTF *scoresLabel = [CCLabelTTF labelWithString:scoresString fontName:@"Courier" fontSize:16.0 dimensions:CGSizeMake(winSize.width, winSize.height/3) hAlignment:kCCTextAlignmentCenter];
        
        [scoresLabel setPosition:ccp(winSize.width / 2, winSize.height / 2)];
        [self addChild:scoresLabel];
        
        // Create button that will take us back to the title screen
        CCLabelTTF *backLabel = [CCLabelTTF labelWithString:@"Back" fontName:@"Arial" fontSize:24.0];
        CCMenuItemLabel *back = [CCMenuItemLabel itemWithLabel:backLabel block:^(id sender)
        {
            //This might not work.
            MenuScene *menuScene = [[MenuScene alloc] init];
            [[CCDirector sharedDirector] replaceScene:menuScene];
        }];
        
        
        // Create menu that contains our buttons
        CCMenu *menu = [CCMenu menuWithItems:back, nil];
        
        // Set position of menu to be below the scores
        [menu setPosition:ccp(winSize.width / 2, scoresLabel.position.y - scoresLabel.contentSize.height)];
        
        // Add menu to layer
        [self addChild:menu z:2];
    }
        return self;
}
@end
