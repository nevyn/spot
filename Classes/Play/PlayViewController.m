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

#import "SpotNavigationController.h"

#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

PlayViewController *GlobalPlayViewController;

@interface PlayViewController ()
@property (readonly) SpotPlayer * defaultPlayer;
-(void)backAction:(id)sender;
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
  //Nibs: 
  //PlayView
  //  with flipview. Flip cover art to show playlist
  //PlayView2
  //  cover art is header of playlist
  NSString *nib = @"PlayView";
  if([[NSUserDefaults standardUserDefaults] boolForKey:@"experimental"])
    nib = @"PlayView2";
	if( ! [super initWithNibName:nib bundle:nil] ) return nil;
	
  AudioSessionInitialize (NULL, NULL, NULL, NULL); 
  AudioSessionSetActive (true);
  UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
  AudioSessionSetProperty (kAudioSessionProperty_AudioCategory, sizeof (sessionCategory), &sessionCategory);
  
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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  trackList.rowHeight = 70;
    trackList.sectionIndexMinimumDisplayRowCount = 20;
  [self.navigationItem setTitleView:titleView];
  

  
  
  //register self as observer for the default player
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerNotification:) name:nil object:[self defaultPlayer]];
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
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [titleView dealloc];
  [super dealloc];
}

#pragma mark
#pragma mark Transitions

-(void)viewWillAppear:(BOOL)animated;
{
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;
}

-(void)viewDidDisappear:(BOOL)animated;
{
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)viewDidAppear:(BOOL)animated;
{
}
-(void)viewWillDisappear:(BOOL)animated;
{
  self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
	[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)selectCurrentTrack;
{
  //bounds check if we are at top of list
  if(trackList.bounds.origin.y > 80 && self.defaultPlayer.currentPlaylist && self.defaultPlayer.currentTrack){
    int idx = [self.defaultPlayer.currentPlaylist.tracks indexOfObject:self.defaultPlayer.currentTrack];
    if(idx != NSNotFound)
      [trackList selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
  }
}


#pragma mark 
#pragma mark Actions
-(void)backAction:(id)sender;
{
  //navbarLeftButton??
  [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)togglePlaying:(id)sender;
{
	if(!self.defaultPlayer.isPlaying)
		[self play];
	else
		[self pause];
}

-(IBAction)pause;
{
  [[SpotSession defaultSession].player pause];
}

-(IBAction)play;
{
  [[SpotSession defaultSession].player play];
}
-(IBAction)next;
{
  [[SpotSession defaultSession].player next];
}

-(IBAction)prev;
{
  [[SpotSession defaultSession].player previous];
}

-(void)showInfoForTrack:(SpotTrack*)track;
{
  titleView.artistLabel.text = track.artist.name;
	titleView.trackLabel.text = track.title;
	titleView.albumLabel.text = track.albumName;
  albumArt.artId = track.coverId;
}

-(void)playerNotification:(NSNotification*)n;
{
  //NSLog(@"PlayerView got notification %@", n);
  if([[n name] isEqual:@"playbackWillStart"]){
    [waitForPlaySpinner startAnimating];
    [playPauseButton setHidden:YES];
  }
  if([[n name] isEqual:@"playbackDidStart"]){
    [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner stopAnimating];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"playbackDidPause"]){
    [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner stopAnimating];
  }
  if([[n name] isEqual:@"playbackDidStop"]){
    [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner stopAnimating];
  }
  if([[n name] isEqual:@"playlistDidChange"]){
    playlistDataSource.playlist = [[n userInfo] valueForKey:@"playlist"];
    if(playlistDataSource.playlist.author || [playlistDataSource.playlist.author length] != 0)
      trackList.sectionHeaderHeight = 44.0;
    else
      trackList.sectionHeaderHeight = 10;
    [trackList reloadData];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"trackDidChange"]){
    [self showInfoForTrack:[[n userInfo] valueForKey:@"track"]];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"trackDidEnd"]){
    //the playing of next track is handled by SpotPlayer
  }
  if([[n name] isEqual:@"playlistDidEnd"]){
    
  }
}

-(SpotPlayer *)defaultPlayer;
{
  return [SpotSession defaultSession].player;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];
  SpotTrack *track = [playlistDataSource.playlist.tracks objectAtIndex:idx];
  if(track.isPlayable){
    [[SpotSession defaultSession].player playTrack:track rewind:YES];
  }
}


@end
