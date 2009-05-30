//
//  LoginViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "LoginViewController.h"
#import "LoggingInController.h"
#import "SpotSession.h"

@implementation LoginViewController
-(id)init;
{
	if( ! [super initWithNibName:@"LoginView" bundle:nil] ) return nil;
	
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
    [super dealloc];
}



-(void)viewWillAppear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
	
	// TODO: Log out here if we're logged in
	
	username.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"username"];
	password.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"password"];
	
	self.title = @"Log in";
	
	if([username.text isEqual:@""])
		[username becomeFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated;
{
  if([[NSUserDefaults standardUserDefaults] boolForKey:@"useAutoLogin"]){
    if(![SpotSession defaultSession].loggedIn)
      [self login];
  }
}
-(void)viewWillDisappear:(BOOL)animated;
{
	//[self.navigationController setNavigationBarHidden:NO animated:animated];
}
-(void)viewDidDisappear:(BOOL)animated;
{
	self.title = @"Log out";
}

- (BOOL)textFieldShouldClear:(UITextField *)textField;
{
	return NO;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if(textField == username)
		[password becomeFirstResponder];
	else
		[self login];
	return YES;
}

-(IBAction)login;
{
	[username resignFirstResponder];
	[password resignFirstResponder];
	[self.navigationController pushViewController:[[[LoggingInController alloc] initLoggingInAs:username.text password:password.text] autorelease] animated:YES];
	[[NSUserDefaults standardUserDefaults] setObject:username.text forKey:@"username"];
	[[NSUserDefaults standardUserDefaults] setObject:password.text forKey:@"password"];
  
}

@end
