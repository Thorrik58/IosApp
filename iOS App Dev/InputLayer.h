//
//  InputLayer.h
//  iOS App Dev
//
//  Created by Þorvarður on 9/25/13.
//  Copyright (c) 2013 Sveinn Fannar Kristjansson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol InputLayerDelgate <NSObject>

- (void)touchBegan;
- (void)touchEnded;

@end

@interface InputLayer : CCLayer

@property (nonatomic, weak) id<InputLayerDelgate> delegate;

@end
