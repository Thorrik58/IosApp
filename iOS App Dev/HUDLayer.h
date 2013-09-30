//
//  HUDLayer.h
//  iOS App Dev
//
//  Created by Þorvarður on 9/29/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//
#import "cocos2d.h"

#import <Foundation/Foundation.h>

@interface HUDLayer : CCLayer {
    CCLabelBMFont * _scoreLabel;
}
- (void)showRestartMenu:(BOOL)won;
- (void)setScoreString:(NSString *)string;


@end
