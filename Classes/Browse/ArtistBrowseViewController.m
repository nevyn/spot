//
//  ArtistBrowseViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "ArtistBrowseViewController.h"
#import "SpotSession.h"
#import "SpotAlbum.h"
#import "AlbumBrowseViewController.h"
#import "SpotNavigationController.h"
#import "ArtistDetailViewController.h"
#import "SpotCell.h"

@interface ArtistBrowseViewController ()
@property (retain) SpotArtist *artist;
@property (retain) NSArray *albums;
@property (retain) NSArray *singles;
@property (retain) NSArray *other;

@end

NSInteger AlbumComparer(SpotAlbum *a, SpotAlbum *b, void * ignore)
{
	// kan lägga in mer fancy grejer här sen...
	return [[NSNumber numberWithInt:b.year] compare:[NSNumber numberWithInt:a.year]];
}


@implementation ArtistBrowseViewController
-(id)initBrowsingArtist:(SpotArtist*)artist_;
{
	if( ! [super initWithNibName:@"ArtistBrowseView" bundle:nil])
		return nil;
  
	self.artist = artist_;
//	self.albums = [artist.albums sortedArrayUsingFunction:AlbumComparer context:NULL];
  
  //Sort into albums, singles, other
  albums = [[NSMutableArray alloc] init];
  singles = [[NSMutableArray alloc] init];
  other = [[NSMutableArray alloc] init];
  for(SpotAlbum *album in artist.albums){
    if([album.type isEqual:@"album"])
      [albums addObject:album];
    else if([album.type isEqual:@"single"])
      [singles addObject:album];
    else
      [other addObject:album];
  }
  
  [albums sortUsingFunction:AlbumComparer context:NULL];
  [singles sortUsingFunction:AlbumComparer context:NULL];
  [other sortUsingFunction:AlbumComparer context:NULL];
	
	return self;
}

- (void)dealloc {
  self.artist = nil;
	self.albums = nil;
  self.singles = nil;
  self.other = nil;
  [super dealloc];
}
/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = artist.name;
  if(artist.portraitId){
    portrait.artId = artist.portraitId;
  }
  albumTable.rowHeight = 70;
//  albumTable.sectionHeaderHeight = 0;
  
  artistName.text = artist.name;
  yearsActive.text = artist.yearsActive;
  popularity.progress = artist.popularity;
  
  infoButton.hidden = ![artist.text length];
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



#pragma mark Table view callbacks

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 3;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
  NSArray *albumList = nil;
  switch (section) {
    case 0: albumList = albums; break;
    case 1: albumList = singles; break;
    case 2: albumList = other; break;
  }
  
  return [albumList count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
  switch(section){
    case 0: return @"Albums";
    case 1: return @"Singles";
    case 2: return @"Other";
  }
  return @"???";
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *SpotCellIdentifier = @"SpotCell";
  
  SpotCell *cell = (SpotCell *)[albumTable dequeueReusableCellWithIdentifier:SpotCellIdentifier];
  if (cell == nil) 
    cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
  
  NSArray *albumList = nil;
  switch (indexPath.section) {
    case 0: albumList = albums; break;
    case 1: albumList = singles; break;
    case 2: albumList = other; break;
  }
  
	int idx = [indexPath indexAtPosition:1];
  SpotAlbum *album = [albumList objectAtIndex:idx];
  cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
  NSString *yearString = album.year ? [NSString stringWithFormat:@"%d", album.year] : @"";
  if(![album.type isEqual:@"album"])
    yearString = [NSString stringWithFormat:@"%@ - %@", album.type, yearString];
  [cell setTitle:album.name
        subTitle:album.artistName
     bottomTitle:yearString
      popularity:album.popularity
           image:YES
         imageId:album.coverId];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];
  
  NSArray *albumList = nil;
  switch (indexPath.section) {
    case 0: albumList = albums; break;
    case 1: albumList = singles; break;
    case 2: albumList = other; break;
  }
  

  SpotAlbum *album = [albumList objectAtIndex:idx];
  [[self navigationController] pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES];
}

-(IBAction)showDetail:(id)sender;
{
  ArtistDetailViewController *detailView = [(ArtistDetailViewController*)[ArtistDetailViewController alloc] initWithArtist:artist];
  [self.navigationController pushViewController:detailView animated:YES];
  [detailView release];
}

@synthesize artist, albums, singles, other;
@end
