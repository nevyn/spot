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

@interface SearchViewController : UIViewController
	<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
{
	IBOutlet UITableView *tableView;
	IBOutlet UISearchBar *searchBar;
	
	struct search_result *searchResults;
	SpotPlaylist *resultPlaylist;
	NSArray *resultArtists;
}
@property (nonatomic, assign) struct search_result *searchResults;
@property (nonatomic, retain) SpotPlaylist *resultPlaylist;
@property (nonatomic, retain) NSArray *resultArtists;
@end
