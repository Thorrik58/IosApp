//
//  HUDLayer.h
//  iOS App Dev
//
//  Created by Þorvarður on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//
#import "cocos2d.h"

#import <Foundation/Foundation.h>

@interface HUDLayer : CCLayer
{
    CCLabelBMFont * _scoreLabel;
    CCLabelBMFont * _statusLabel;

}
- (void)showRestartMenu:(BOOL)won highScore:(BOOL) highScore;
- (void)setScoreString:(NSString *)string;
- (void)setStatusString:(NSString *)string;


@end
