//
//  AlbumBrowseViewController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpotAlbum.h"

@interface AlbumBrowseViewController : UIViewController {
  SpotAlbum *album;
	IBOutlet UIImageView *albumArt;
}
-(id)initBrowsingAlbum:(SpotAlbum*)album;
@end
