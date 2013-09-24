//
//  AppDelegate.h
//  IosApp
//
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

// Added only for iOS 6 support
@interface NavigationController : UINavigationController <CCDirectorDelegate>
@end

@interface AppController : NSObject <UIApplicationDelegate>
{
    UIWindow *_window;
    NavigationController *_navController;
    CCDirectorIOS *_director;
}


@end
