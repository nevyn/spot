//
//  SpotAppDelegate.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "SpotAppDelegate.h"
#import "CoSpotify.h"

#import "LoginViewController.h"
#import "ProfileViewController.h"
#import "PlaylistsViewController.h"
#import "SearchViewController.h"
#import "PlayViewController.h"

#import "SpotNavigationController.h"

@implementation SpotAppDelegate

@synthesize window, loginNav, tabs;

#import "SpotURI.h"

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {   
	
	///// Prepare the main UI
	// Warm it up
	[[PlayViewController defaultController] view];
	
	self.tabs = [[[UITabBarController alloc] init] autorelease];
	
	// Profile page
	UINavigationController *profilePage;
	{
		profilePage = [[[SpotNavigationController alloc] init] autorelease];
		profilePage.title = @"Profile";
		
		ProfileViewController *profile = [[[ProfileViewController alloc] init] autorelease];
		[profilePage pushViewController:profile animated:NO];
	}
	
	// Playlists
	UINavigationController *playlistPage;
	{
		playlistPage = [[[SpotNavigationController alloc] init] autorelease];
		
		PlaylistsViewController *playlists = [[[PlaylistsViewController alloc] init] autorelease];
		[playlistPage pushViewController:playlists animated:NO];
	}
	
	// Search
	SpotNavigationController *searchPage;
	{
		searchPage = [[[SpotNavigationController alloc] init] autorelease];
		
		SearchViewController *search = [[[SearchViewController alloc] init] autorelease];
		[searchPage pushViewController:search animated:NO];
    searchNav = searchPage;
	}
    
	
	NSArray *pages = [NSArray arrayWithObjects:
					  profilePage,
					  searchPage,
					  playlistPage,
					  nil];
	
	// Add it to the root
	[tabs setViewControllers:pages animated:NO];
	
	[tabs viewWillAppear:NO];
	[window addSubview:tabs.view];
	[tabs viewDidAppear:NO];
	
	///// Prepare to login
	LoginViewController *login = [[[LoginViewController alloc] init] autorelease];
	self.loginNav = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
	
	[self.tabs presentModalViewController:self.loginNav animated:NO];
	
	/// Display it!
  [window makeKeyAndVisible];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedinNotification:) name:@"loggedin" object:nil];
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
	//[[SpotSession defaultSession] cleanup];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
{
  openURL = [url retain];
  return YES; //probably dunno yet need to login first LOL
}


-(void)loggedinNotification:(NSNotification*)n;
{
  //check if we got called by URL
  NSURL *url = openURL;
  //  url = [NSURL URLWithString:@"http://open.spotify.com/album/74ikOPgco70HHuxrLydWjo"]; //other album
  //  url = [NSURL URLWithString:@"http://open.spotify.com/album/6sh0IoRG4pkpDOSCByH5cV"]; //album
  //  url = [NSURL URLWithString:@"http://open.spotify.com/track/2QX7lSCOT4OESPUYzvR2wB"]; //track
  //  url = [NSURL URLWithString:@"http://open.spotify.com/artist/5K0IAf5mrtln8thyowRn2X"]; //artist
  //  url = [NSURL URLWithString:@"http://open.spotify.com/search/mumin"]; //search
  //  url = [NSURL URLWithString:@"http://open.spotify.com/user/gujjdo/playlist/1qILpejEO16tlJDGEdX5Yq"]; //playlist
    url = [NSURL URLWithString:@"spotify:user:gujjdo:playlist:1qILpejEO16tlJDGEdX5Yq"]; //playlist 
  if(url){
    [searchNav openURL:url];
  }
  tabs.selectedIndex = 1;
}



#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];

  [openURL release];
	self.loginNav = nil;
	self.tabs = nil;
	self.window = nil;
	[super dealloc];
}


@end

