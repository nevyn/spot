//
//  SpotPlaylistTableViewDataSource.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotPlaylistTableViewDataSource.h"
#import "SpotPlaylist.h"
#import "SpotTrack.h"


@implementation SpotPlaylistTableViewDataSource

@synthesize playlist;

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

-(void)reloadData;
{
  //TODO: tell table to reload
}

-(void)playlistChanged:(NSNotification*)n;
{
  [self reloadData];
}

-(void)setPlaylist:(SpotPlaylist *)newList;
{
  [newList retain];
  if(playlist)
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:playlist];
  [playlist release];
  
  if(newList)
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playlistChanged:) name:@"changed" object:newList];
  
  playlist = newList;
  
  [self reloadData];
}

#pragma mark Table view callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
  return playlist ? [playlist.playableTrackList.tracks count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
  return playlist.name;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView_ dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
  }
  
	int idx = [indexPath indexAtPosition:1]; idx = idx;
  SpotTrack *track = [playlist.playableTrackList.tracks objectAtIndex:idx];
  cell.accessoryType = track.playable ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
  cell.text = [NSString stringWithFormat:@"%@", track.title];
  
  return cell;
}

@end
