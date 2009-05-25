//
//  ArtistBrowseViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotArtist.h"

@interface ArtistBrowseViewController : UIViewController {
  SpotArtist *artist;
  IBOutlet UIImageView *portrait;
}
-(id)initBrowsingArtist:(SpotArtist*)artist;
@end
