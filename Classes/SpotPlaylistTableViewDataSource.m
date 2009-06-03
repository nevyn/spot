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
#import "SpotCell.h"

@implementation SpotPlaylistTableViewDataSource

@synthesize playlist, cellAccessoryType;

-(id)init;
{
  if(![super init]) return nil;
  cellAccessoryType = UITableViewCellAccessoryNone;
  return self;
}

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
  return playlist ? [playlist.tracks count] : 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
  if(playlist.author || [playlist.author length] != 0)
    return [NSString stringWithFormat:@"%@\nby %@", playlist.name, playlist.author];
  return @"";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *SpotCellIdentifier = @"SpotCell";
  
	int idx = [indexPath indexAtPosition:1]; idx = idx;
  SpotTrack *track = [playlist.tracks objectAtIndex:idx];

  SpotCell *cell = (SpotCell *)[tableView_ dequeueReusableCellWithIdentifier:SpotCellIdentifier];
  if (cell == nil) 
    cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];

  cell.accessoryType = cellAccessoryType;
  
  [cell setTitle:track.title 
        subTitle:track.artist.name 
    // bottomTitle:[NSString stringWithFormat:@"length: %.2f", track.length/60.0]
     bottomTitle:track.albumName
      popularity:track.popularity
           image:NO 
         imageId:nil];
  
  return cell;
}

@end
