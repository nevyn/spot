//
//  AlbumBrowseViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "AlbumBrowseViewController.h"
#import "SpotSession.h"
#import "SpotTrack.h"
#import "PlayViewController.h"

@implementation AlbumBrowseViewController
-(id)initBrowsingAlbum:(SpotAlbum*)album_;
{
	if( ! [super initWithNibName:@"AlbumBrowseView" bundle:nil])
		return nil;
  
  album = [album_ retain];
  self.title = album.name;
  
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
  
  if(album.coverId){
    albumArt.artId = album.coverId;
  }
  [albumName setText:album.name];
  [popularity setValue:album.popularity];
  
  playlistDataSource.playlist = album.playlist;
  [tracks reloadData];
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
  [album release];
  [super dealloc];
}


#pragma mark Table view callbacks

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];
  
  SpotTrack *track = [album.playlist.playableTrackList.tracks objectAtIndex:idx];
  if(track.playable){
    [[SpotSession defaultSession].player playTrack:track rewind:NO];
    [self.navigationController pushViewController:[PlayViewController defaultController] animated:YES];
  }
//  [[self navigationController] pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES];
}



@end
