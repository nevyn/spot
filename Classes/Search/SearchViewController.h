//
//  SearchViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotPlaylist.h"
#import "SpotSearch.h"

typedef enum{
  ShowArtists,
  ShowAlbums,
  ShowTracks
}SearchShowType;

@interface SearchViewController : UIViewController
	<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UISearchBar *searchBar;
  
  SearchShowType showType;
	
	SpotSearch *searchResults;
}
-(id)initWithSearch:(SpotSearch*)search;

-(void)searchForString:(NSString*)string;

-(IBAction)headerChanged:(id)sender;

@property (nonatomic, assign) SpotSearch *searchResults;

@end
