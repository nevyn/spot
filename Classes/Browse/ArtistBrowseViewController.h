//
//  ArtistBrowseViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotArtist.h"
#import "SpotImageView.h"


@interface ArtistBrowseViewController : UIViewController <UITableViewDelegate, UIWebViewDelegate> {
  SpotArtist *artist;
  IBOutlet SpotImageView *portrait;
  IBOutlet UITableView *albumTable;
  
  IBOutlet UILabel *artistName;
  IBOutlet UILabel *yearsActive;
  IBOutlet UIProgressView *popularity;
  
  IBOutlet UIButton *infoButton;
  
  NSMutableArray *albums;
  NSMutableArray *singles;
  NSMutableArray *other;
}

-(id)initBrowsingArtist:(SpotArtist*)artist;

-(IBAction)showDetail:(id)sender;

@end
