//
//  SpotAppDelegate.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "SpotNavigationController.h"

@interface SpotAppDelegate : NSObject <UIApplicationDelegate> {
  IBOutlet UITabBarController *tabs;
	UINavigationController *loginNav;
  UIWindow *window;
  NSURL *openURL;
  SpotNavigationController *searchNav;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabs;
@property (nonatomic, retain) IBOutlet UINavigationController *loginNav;

-(void)loggedinNotification:(NSNotification*)n;

@end

