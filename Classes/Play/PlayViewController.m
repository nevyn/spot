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

-(void)selectCurrentTrack;
{
  if(self.defaultPlayer.currentPlaylist && self.defaultPlayer.currentTrack){
    int idx = [self.defaultPlayer.currentPlaylist.tracks indexOfObject:self.defaultPlayer.currentTrack];
    if(idx != NSNotFound)
      [trackList selectRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] animated:YES scrollPosition:UITableViewScrollPositionMiddle];
  }
}


#pragma mark 
#pragma mark Actions
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
  [[SpotSession defaultSession].player playNextTrack];
}

-(IBAction)prev;
{
  [[SpotSession defaultSession].player playPreviousTrack];
}

-(void)showInfoForTrack:(SpotTrack*)track;
{
  artistLabel.text = track.artist.name;
	trackLabel.text = track.title;
	albumLabel.text = track.albumName;
  albumArt.artId = [SpotId coverId:(char*)[track.coverId cStringUsingEncoding:NSASCIIStringEncoding]];
}

-(void)playerNotification:(NSNotification*)n;
{
  NSLog(@"PlayerView got notification %@", n);
  if([[n name] isEqual:@"willplay"]){
    [waitForPlaySpinner setHidden:NO];
    [playPauseButton setHidden:YES];
  }
  if([[n name] isEqual:@"play"]){
    [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner setHidden:YES];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"pause"]){
    [playPauseButton setImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner setHidden:YES];
  }
  if([[n name] isEqual:@"stop"]){
    [playPauseButton setImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal|UIControlStateHighlighted|UIControlStateDisabled|UIControlStateSelected];
    [playPauseButton setHidden:NO];
    [waitForPlaySpinner setHidden:YES];
  }
  if([[n name] isEqual:@"playlist"]){
    playlistDataSource.playlist = [[n userInfo] valueForKey:@"playlist"];
    [trackList reloadData];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"track"]){
    [self showInfoForTrack:[[n userInfo] valueForKey:@"track"]];
    [trackList reloadData];
    [self selectCurrentTrack];
  }
  if([[n name] isEqual:@"trackDidEnd"]){
    [[SpotSession defaultSession].player playNextTrack];
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


-(void)didTouchLabel:(id)sender;
{
  SpotPlayer *player = [SpotSession defaultSession].player;
  if(sender == artistLabel){
    [self.navigationController showArtist:player.currentTrack.artist];
  } else if(sender == albumLabel){
    [self.navigationController showAlbum:player.currentTrack.album];
  }
}

@end
