//
//  SpotAppDelegate.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

@interface SpotAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

