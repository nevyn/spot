//
//  SearchViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SearchViewController.h"
#import "SpotNavigationController.h"
#import "SpotSession.h"
#import "SpotArtist.h"
#import "SpotTrack.h"
#import "SpotSearch.h"

#import "AlbumBrowseViewController.h"
#import "ArtistBrowseViewController.h"
#import "PlayViewController.h"

#import "SpotCell.h"


@implementation SearchViewController

#pragma mark 
#pragma mark Memory and init

- (id)init;
{
    if ( ! [super initWithNibName:@"SearchView" bundle:nil]) return nil;
	
	self.title = @"Search";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
	
    return self;
}


-(id)initWithSearch:(SpotSearch*)search;
{
//  if( ! [super initWithNibName:@"SearchView" bundle:nil])
  if( ! [self init] )
		return nil;
  
  self.searchResults = search;
  
	return self;
}

- (void)dealloc {
    [super dealloc];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  [super viewDidLoad];
  //UISegmentedControl *header = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Artists", @"Albums", @"Tracks", nil]];
  tableView.rowHeight = 70;
  //tableView.tableHeaderView = header;
  searchBar.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastSearch"];
}

-(void)viewDidAppear:(BOOL)animated{
  [super viewDidAppear:animated];
}
    

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark 
#pragma mark Transitions
-(void)viewWillAppear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
  
  if([searchBar.text length] == 0)
    [searchBar becomeFirstResponder];
  else if(!searchResults)
    
    [self searchForString:searchBar.text];
}

-(void)viewWillDisappear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark 
#pragma mark Table view callbacks
enum {
  SuggestionSection,
	ArtistsSection,
	AlbumsSection,
  TracksSection
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 1;
	return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
{
  return 0;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 0;
	
	switch (showType) {
		case ShowArtists: return searchResults.artists.count;
		case ShowAlbums:  return searchResults.albums.count;
		case ShowTracks:  return searchResults.tracks.count;
	}
	return 0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return @"Search results";
	
	return @"???";
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
  static NSString *SpotCellIdentifier = @"AlbumCell";
  UITableViewCell *the_cell = nil;
  
  BOOL loadImage = [[NSUserDefaults standardUserDefaults] boolForKey:@"coversInSearch"];

	int idx = [indexPath indexAtPosition:1]; idx = idx;
	switch(showType) {
		case ShowArtists: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if (cell == nil) 
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
            
			SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
      
      
      [cell setTitle:artist.name
            subTitle:artist.genres
         bottomTitle:artist.yearsActive
          popularity:artist.popularity 
               image:loadImage
             imageId:loadImage ? artist.portraitId : nil];
      
      the_cell = cell;
		} break;
		case ShowAlbums: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if(!cell)
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
      
			SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
      
      [cell setTitle:album.name
            subTitle:album.artistName
         bottomTitle:album.year ? [NSString stringWithFormat:@"%d", album.year] : nil
          popularity:album.popularity 
               image:loadImage 
             imageId:loadImage ? album.coverId : nil];
      
      if(!album.allowed){
        cell.bottomTitle.text = @"Unavailable in your country";
      }
      
      the_cell = cell;
		} break;
    case ShowTracks: {
      SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
      if(!cell)
        cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
      
			SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			//cell.text = [NSString stringWithFormat:@"%@", track.title];
      [cell setTitle:track.title 
            subTitle:track.artist.name 
         bottomTitle:track.albumName 
          popularity:track.popularity 
               image:NO 
             imageId:nil];
      
      the_cell = cell;
		} break;
      
	}

  return the_cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [searchBar resignFirstResponder];
	int idx = [indexPath indexAtPosition:1];
	switch(showType) {
		case ShowArtists: {
			SpotArtist *artist = [searchResults.artists objectAtIndex:idx];
      //Get the fullprofile artist
      artist = [[SpotSession defaultSession] artistById:artist.id];
      [self.navigationController showArtist:artist];
		} break;
		case ShowAlbums: {
			SpotAlbum *album = [searchResults.albums objectAtIndex:idx];
      //get the fullprofile album
      album = [[SpotSession defaultSession] albumById:album.id];
			[self.navigationController showAlbum:album];
			break;
		}
		case ShowTracks: {
			SpotTrack *track = [searchResults.tracks objectAtIndex:idx];
      SpotPlaylist *playlist = [[[SpotPlaylist alloc] initWithName:searchResults.query author:@"search" tracks:searchResults.tracks] autorelease];
			[[SpotSession defaultSession].player playPlaylist:playlist firstTrack:track];
      [self.navigationController showPlayer];
		} break;
	}
}

#pragma mark 
#pragma mark Search bar callbacks
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar;
{
	return [SpotSession defaultSession].loggedIn == YES;
}
- (void)searchBar:(UISearchBar *)searchBar_ textDidChange:(NSString *)searchText;
{
	// Do short search maybe
}

-(void)searchForString:(NSString*)string;
{
  // Do extensive search
	self.searchResults = nil;
  //NSLog(@"searching");
	self.searchResults = [SpotSearch searchFor:string maxResults:50];
  //save last search if it generated any results
  if(searchResults && searchResults.totalAlbums || searchResults.totalTracks || searchResults.totalArtists){
    [[NSUserDefaults standardUserDefaults] setObject:string forKey:@"lastSearch"];
  }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_;  
{
  [searchBar resignFirstResponder];
  [self searchForString:[searchBar_ text]];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_;  
{
  [searchBar resignFirstResponder];
}


-(void)headerChanged:(id)sender;
{
  [searchBar resignFirstResponder];
  UISegmentedControl *e = sender;
  showType = (SearchShowType)e.selectedSegmentIndex;
  [tableView reloadData];
}

#pragma mark 
#pragma mark Accessors
@synthesize searchResults;
-(void)setSearchResults:(SpotSearch*)searchResults_;
{
	[searchResults_ retain];
  [searchResults release];
  searchResults = searchResults_;
  NSLog(@"SearchResults: %@", searchResults);
	[tableView reloadData];
}
@end
