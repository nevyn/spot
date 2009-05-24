//
//  PlayViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "PlayViewController.h"
#import "SpotSession.h"
#import "SpotTrack.h"
#import "SpotArtist.h"

PlayViewController *GlobalPlayViewController;

@interface PlayViewController ()
@property (readwrite, retain, nonatomic) SpotPlaylist *currentPlaylist;
@property (readwrite, retain, nonatomic) SpotTrack *currentTrack;
@end


@implementation PlayViewController
+defaultController;
{
	if(!GlobalPlayViewController)
		GlobalPlayViewController = [[PlayViewController alloc] init];
	return GlobalPlayViewController;
}
-init;
{
	if( ! [super initWithNibName:@"PlayView" bundle:nil] ) return nil;
	
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

#pragma mark
#pragma mark Transitions
-(void)viewDidAppear:(BOOL)animated;
{
	self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}
-(void)viewWillDisappear:(BOOL)animated;
{
	self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}


#pragma mark 
#pragma mark Playing
-(void)playPlaylist:(SpotPlaylist*)playlist;
{
	[self playPlaylist:playlist startingAtTrack:nil];
}
-(void)playPlaylist:(SpotPlaylist*)playlist startingAtTrack:(SpotTrack*)track;
{
	if(!playlist) {
		if(track.playlist)
			playlist = track.playlist;
		else
			playlist = [[[SpotPlaylist alloc] initWithTrack:track] autorelease];
	}
	
	if(!track)
		track = [playlist.tracks objectAtIndex:0];
	
	if( ! [playlist.tracks containsObject:track] )
		[NSException raise:NSInvalidArgumentException format:@"The 'track' argument must be in the playlist given"];
	
	self.currentPlaylist = playlist;
	self.currentTrack = track;
}
-(void)playTrack:(SpotTrack*)track;
{
	[self playPlaylist:nil startingAtTrack:track];
}


#pragma mark 
#pragma mark Actions
-(IBAction)togglePlaying:(id)sender;
{
	if(!self.playing)
		[self play];
	else
		[self pause];
}
-(IBAction)pause;
{
	[playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
}
-(IBAction)play;
{
	[playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
}
-(IBAction)next;
{
	
}
-(IBAction)prev;
{
	
}


#pragma mark 
#pragma mark Properties
@synthesize currentPlaylist, currentTrack;
-(void)setCurrentTrack:(SpotTrack*)newTrack;
{
	if(newTrack == currentTrack) return;
	
	if(!artistLabel) {
		NSLog(@"Hmmm");
	}
	despotify_stop([SpotSession defaultSession].session);
	[newTrack retain];
	[currentTrack release];
	currentTrack = newTrack;
	if( ! newTrack )
		return;
	
	artistLabel.text = newTrack.artist.name;
	trackLabel.text = newTrack.title;
	albumLabel.text = newTrack.albumName;
	
	despotify_play([SpotSession defaultSession].session, newTrack.track, NO);
	// todo: notice end of song and play next
}

-(BOOL)playing;
{
	return self.currentTrack != nil;
}
@end
