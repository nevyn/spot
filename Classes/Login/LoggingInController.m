//
//  LoggingInController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "LoggingInController.h"
#import "CoSpotify.h"

@implementation LoggingInController
@synthesize username, password;
-(id)initLoggingInAs:(NSString*)name_ password:(NSString*)password_;
{
	if( ! [super initWithNibName:@"LoggingIn" bundle:nil] ) return nil;
	self.username = name_;
	self.password = password_;
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
	self.username = self.password = nil;
    [super dealloc];
}



-(void)createSessionAndLogin;
{
	
	spinner.hidden = YES;
	
	NSError *err;
	BOOL success = [[SpotSession defaultSession] authenticate:self.username password:self.password error:&err];
	if(!success) {
		error.text = [NSString stringWithFormat:@"I couldn't log you in: %@", err.localizedDescription];
		tryAgain.hidden = error.hidden = NO;
		return;
	}
	
	UINavigationController *navController = self.navigationController;
	[navController setNavigationBarHidden:YES animated:NO];
	
	[[self retain] autorelease]; // We will disappear after the pop
	
	NSMutableArray *controllers = [[navController.viewControllers mutableCopy] autorelease];
	[controllers removeLastObject];
	navController.viewControllers = controllers;
	
	[navController dismissModalViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated;
{
	self.title = @"Logging in…";
	tryAgain.hidden = error.hidden = YES;
	spinner.hidden = NO;
}
-(void)viewDidAppear:(BOOL)animated;
{
	[self createSessionAndLogin];
}

-(IBAction)tryAgain;
{
	[self.navigationController popViewControllerAnimated:YES];
}

@end
