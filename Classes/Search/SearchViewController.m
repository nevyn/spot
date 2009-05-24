//
//  SearchViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SearchViewController.h"
#import "SpotSession.h"
#import "SpotArtist.h"
#import "SpotTrack.h"

#import "AlbumBrowseViewController.h"
#import "ArtistBrowseViewController.h"

@implementation SearchViewController

#pragma mark 
#pragma mark Memory and init

- (id)init;
{
    if ( ! [super initWithNibName:nil bundle:nil]) return nil;
	
	self.title = @"Search";
	self.tabBarItem = [[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0] autorelease];
	
    return self;
}

- (void)dealloc {
    [super dealloc];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark 
#pragma mark Transitions
-(void)viewWillAppear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated;
{
	[self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark 
#pragma mark Table view callbacks
enum {
	TracksSection,
	ArtistsSection,
	AlbumsSection
};

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 1;
	
	return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return 0;
	
	switch (section) {
		case ArtistsSection: return resultArtists.count;
		case TracksSection: return resultPlaylist.tracks.count;
		case AlbumsSection: return searchResults->total_albums;
	}
	return 0;	
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different
{
	if( ! [SpotSession defaultSession].loggedIn || !searchResults) return @"Search results";
	
	switch (section) {
		case ArtistsSection: return @"Artists";
		case TracksSection: return @"Tracks";
		case AlbumsSection: return @"Albums";
	}
	return @"???";
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
	switch([indexPath indexAtPosition:0]) {
		case ArtistsSection: {
			SpotArtist *artist = [resultArtists objectAtIndex:idx];
			
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.text = artist.name;
		} break;
		case TracksSection: {
			SpotTrack *track = [resultPlaylist.tracks objectAtIndex:idx];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.text = [NSString stringWithFormat:@"%@ - %@", track.artist.name, track.title];
		} break;
		case AlbumsSection: {
			
			cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
			cell.text = @"An album";
		} break;
	}
	
	// Configure the cell. 

	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int idx = [indexPath indexAtPosition:1];
	switch([indexPath indexAtPosition:0]) {
		case TracksSection: {
			
		} break;
		case ArtistsSection: {
			SpotArtist *artist = [resultArtists objectAtIndex:idx];
			
			[[self navigationController] pushViewController:[[[ArtistBrowseViewController alloc] initBrowsingArtist:artist] autorelease] animated:YES];
		} break;
		case AlbumsSection: {
			SpotAlbum *album = nil;
			
			[[self navigationController] pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES];
			break;
		}
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_;  
{
	// Do extensive search
	[searchBar resignFirstResponder];
	
	self.searchResults = NULL;
	
	self.searchResults = despotify_search([SpotSession defaultSession].session, (char*)[searchBar.text UTF8String], 50);
}


#pragma mark 
#pragma mark Accessors
@synthesize searchResults, resultPlaylist, resultArtists;
-(void)setSearchResults:(struct search_result*)searchResults_;
{
	// 1. Clean up
	if(searchResults)
		despotify_free_search(searchResults);
	
	self.resultPlaylist = nil;
	self.resultArtists = nil;
	
	searchResults = searchResults_;
	
	
	// No new results? Don't continue.
	if(!searchResults) goto endSetSearchResults;
	
	
	// 2. Setup the browsable structures
	self.resultPlaylist = [[[SpotPlaylist alloc] initWithPlaylist:searchResults->playlist] autorelease];
	
	NSMutableArray *artists = [NSMutableArray array];
	for(struct artist *art = searchResults->artists; art != NULL; art = art->next)
		[artists addObject:[[[SpotArtist alloc] initWithArtist:art] autorelease]];
	self.resultArtists = artists;
	
	
endSetSearchResults:
	[tableView reloadData];
}
@end
