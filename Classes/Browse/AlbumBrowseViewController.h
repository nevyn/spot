//
//  AlbumBrowseViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotAlbum.h"
#import "SpotImageView.h"
#import "SpotTouchableLabel.h"
#import "SpotPlaylistTableViewDataSource.h"

@interface AlbumBrowseViewController : UIViewController <UITableViewDelegate> {
  SpotAlbum *album;
  IBOutlet SpotPlaylistTableViewDataSource *playlistDataSource;
	IBOutlet SpotImageView *albumArt;
  IBOutlet UITableView *tracks;
  IBOutlet UIProgressView *popularity;
  IBOutlet UILabel *albumName;
  IBOutlet SpotTouchableLabel *artistName;
}
-(id)initBrowsingAlbum:(SpotAlbum*)album;

-(IBAction)showArtist:(id)sender;

@end
