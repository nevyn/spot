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
  IBOutlet UIWebView *artistText;
  IBOutlet UITableView *albums;
  IBOutlet UISlider *popularity;
}
-(id)initBrowsingArtist:(SpotArtist*)artist;
@end
