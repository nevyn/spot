//
//  SpotArtist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SpotId.h"
#import "despotify.h"

@interface SpotArtist : NSObject {
	struct artist artist;
  struct artist_browse artistBrowse;
  
  BOOL browsing;
  
  NSArray *albums;
}
-(id)initWithArtist:(struct artist*)artist;
-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse;

@property (readonly) SpotId *id;
@property (readonly) NSString *name;
@property (readonly) float popularity;
@property (readonly) UIImage *portrait;

//Need to be inited from _browse for these props
@property (readonly) NSArray *albums;
@property (readonly) NSString *yearsActive;
@property (readonly) NSString *genres;

@end
