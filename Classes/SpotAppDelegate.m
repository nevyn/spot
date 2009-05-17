//
//  SpotAppDelegate.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "SpotAppDelegate.h"
#import "LoginViewController.h"

@implementation SpotAppDelegate

@synthesize window;
@synthesize navigationController;


#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
	[navigationController viewWillAppear:NO];
	[window addSubview:[navigationController view]];
	[navigationController viewDidAppear:NO];
	[navigationController setNavigationBarHidden:YES];
	
	LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
	[login viewWillAppear:NO];
	[navigationController pushViewController:login animated:NO];
	[login viewDidAppear:NO];
	
    [window makeKeyAndVisible];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

