//
//  ProfileViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-19.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "ProfileViewController.h"
#import "SpotSession.h"

@implementation ProfileViewController
-(id)init;
{
	if( ! [super initWithNibName:@"Profile" bundle:nil] ) return nil;
	self.title = @"Profile";
	self.tabBarItem.image = [UIImage imageNamed:@"profile.png"];
	
	return self;
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(void)viewWillAppear:(BOOL)animated;
{
	SpotSession *session = [SpotSession defaultSession];
	if(session.loggedIn) {
		username.text = session.username;
		country.text = session.country;
		accountType.text = session.accountType;
		expiry.text = session.expires.description;
		server.text = [NSString stringWithFormat:@"%@:%d", session.serverHost, session.serverPort];
		lastServerContact.text = session.lastPing.description;
	} else {
		username.text = @"(Not logged in)";
		country.text = @"";
		accountType.text = @"";
		expiry.text = @"";
		server.text = @"(Not connected)";
		lastServerContact.text = @"";
	}
  autoLoginSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"useAutoLogin"];
  coversInSearchSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"coversInSearch"];
  experimentalSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"experimental"];
  
  UIScrollView *scroller = (UIScrollView*)self.view;
  scroller.contentSize = ((UIView*)[scroller.subviews objectAtIndex:0]).bounds.size;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


-(IBAction)toggleAutoLogin:(UISwitch*)sender;
{
  [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"useAutoLogin"];
}

-(IBAction)toggleCovers:(UISwitch*)sender;
{
  [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"coversInSearch"];
}

-(IBAction)toggleExperimental:(UISwitch*)sender;
{
  [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"experimental"];
}

@end
