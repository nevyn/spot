//
//  ArtistBrowseViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotArtist.h"

@interface ArtistBrowseViewController : UIViewController <UITableViewDelegate>{
  SpotArtist *artist;
  IBOutlet UIImageView *portrait;
  IBOutlet UILabel *artistName;
  IBOutlet UITableView *albums;
  IBOutlet UISlider *popularity;
}
-(id)initBrowsingArtist:(SpotArtist*)artist;
@end
