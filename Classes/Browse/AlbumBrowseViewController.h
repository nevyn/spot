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
#import "SpotPlaylistTableViewDataSource.h"

@interface AlbumBrowseViewController : UIViewController <UITableViewDelegate> {
  SpotAlbum *album;
  IBOutlet SpotPlaylistTableViewDataSource *playlistDataSource;
	IBOutlet SpotImageView *albumArt;
  IBOutlet UILabel *albumName;
  IBOutlet UITableView *tracks;
  IBOutlet UISlider *popularity;
}
-(id)initBrowsingAlbum:(SpotAlbum*)album;

@end
