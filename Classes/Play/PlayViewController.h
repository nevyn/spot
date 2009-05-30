//
//  PlayViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotPlaylist.h"
#import "SpotImageView.h"
#import "SpotPlaylistTableViewDataSource.h"
#import "SpotTouchableLabel.h"
#import "PlayTitleView.h"

@interface PlayViewController : UIViewController {

  BOOL isPlaying;
	
	IBOutlet UIButton *playPauseButton;
  IBOutlet UIActivityIndicatorView *waitForPlaySpinner;
  
  IBOutlet SpotPlaylistTableViewDataSource *playlistDataSource;
	
	IBOutlet SpotImageView *albumArt;
  IBOutlet UITableView *trackList;
  IBOutlet UIView *flipView;
  
  IBOutlet PlayTitleView *titleView;
}
+defaultController;

-(IBAction)togglePlaying:(id)sender;
-(IBAction)pause;
-(IBAction)play;
-(IBAction)next;
-(IBAction)prev;

//-(IBAction)takeLooping:(id)sender;
//-(IBAction)takeShuffling:(id)sender;

-(void)playerNotification:(NSNotification*)n;

@end
