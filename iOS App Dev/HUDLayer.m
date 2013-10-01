//
//  HUDLayer.m
//  iOS App Dev
//
//  Created by Þorvarður on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import "HUDLayer.h"
#import "GameScene.h"
#import "MenuScene.h"

@implementation HUDLayer


- (id)init {
    
    if ((self = [super init])) {
        
        CGSize _winSize = [CCDirector sharedDirector].winSize;
        //TODO: Z INDEX FIXES!
        //Score label set up to keep track of score
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial-hd.fnt"];
            _statusLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial-hd.fnt"];
        } else {
            _scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial.fnt"];
            _statusLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Arial.fnt"];
        }
        _scoreLabel.position = ccp(_winSize.width* 0.2, _winSize.height * 0.9);
        [self addChild:_scoreLabel z:10];
        
        _statusLabel.position = ccp(_winSize.width* 0.8, _winSize.height * 0.9);
        [self addChild:_statusLabel z:10];
    }
    return self;
}

- (void)setScoreString:(NSString *)string {
    _scoreLabel.string = string;
}

- (void)setStatusString:(NSString *)string {
    _statusLabel.string = string;
}

- (void)menuTapped:(id)sender {
    // Reload the current scene
    CCScene *scene = [MenuScene init];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:scene]];
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
    CCLabelTTF *resultLabel = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:24.0];
    resultLabel.color = ccc3(252,214,103);
    resultLabel.scale = 0.1;
    resultLabel.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:resultLabel];
    
    CCLabelTTF *restartLabel = [CCLabelTTF labelWithString:@"Restart" fontName:@"Arial" fontSize:24.0];
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    
     //Set the position and color of 'restartItem'
    restartItem.position = ccp(winSize.width/1.5, winSize.height * 0.4);
    [self setColorAndScale:restartItem];
    
    CCLabelTTF *menuLabel = [CCLabelTTF labelWithString:@"Main Menu" fontName:@"Arial" fontSize:24.0];
    //CCMenuItemLabel *menuB = [CCMenuItemLabel itemWithLabel:menuLabel target:self selector:@selector(menuTrapped:)];
    CCMenuItemLabel *menuB = [CCMenuItemLabel itemWithLabel:menuLabel block:^(id sender)
    {
        MenuScene *menuScene = [[MenuScene alloc] init];
        [[CCDirector sharedDirector] replaceScene:menuScene];
    }];
    
    //Set the position and color of 'Main Menu'
    menuB.position =ccp(winSize.width/3, winSize.height * 0.4);
    [self setColorAndScale:menuB];
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem,menuB, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    //Actions for epic effects!
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [resultLabel runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [menuB runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

- (void) setColorAndScale:(CCMenuItemLabel*) label
{
    label.color = ccc3(252,214,103);
    label.scale = 0.1;
}

@end
