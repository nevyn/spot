//
//  ArtistDetailViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-27.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "ArtistDetailViewController.h"
#import "SpotNavigationController.h"

@implementation ArtistDetailViewController


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithArtist:(SpotArtist*)artist_;
{
	if ( ! [super initWithNibName:@"ArtistDetailView" bundle:nil]) return nil;
	
	artist = artist_;
  self.title = [NSString stringWithFormat:@"%@", artist.name];
	
	return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  NSString *html = [NSString stringWithFormat:@"<html><body>%@</body></html>", artist.text];
  [webView loadHTMLString:html baseURL:[NSURL URLWithString:@"http://www.spotify.com"]];
  webView.delegate = self;
}

//for spotify links
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType;
{
	NSURL *url = request.URL;
	if([url.scheme isEqual:@"spotify"]){
    [self.navigationController openURL:url];
  }
	return YES;
}


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


@end
