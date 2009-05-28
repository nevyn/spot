//
//  SpotAlbum.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotArtist.h"
#import "SpotPlaylist.h"
#import "SpotItem.h"

@interface SpotAlbum : SpotItem {
	struct album album;
  struct album_browse albumBrowse;
  BOOL browsing;
  NSArray *tracks;
  
  SpotPlaylist *playlist;
}
-(id)initWithAlbum:(struct album*)album;
-(id)initWithAlbumBrowse:(struct album_browse*)album;

-(void)loadMoreInfo;

-(NSComparisonResult)compare:(SpotAlbum*)other;

@property (readonly, nonatomic) BOOL browsing;


//shared
@property (readonly) NSString *name;
@property (readonly) SpotId *coverId;
@property (readonly) float popularity;

//album only
@property (readonly) NSString *artistName;
@property (readonly) SpotId *artistId;

//browse only
@property (readonly) int year;
@property (readonly) SpotPlaylist *playlist;
           
@end
