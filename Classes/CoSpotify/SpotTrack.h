//
//  SpotTrack.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotId.h"
#import "despotify.h"
#import "SpotArtist.h"

#import <UIKit/UIKit.h>
#import "SpotItem.h"

@class SpotPlaylist;
@class SpotURI;

@interface SpotTrack : SpotItem {
	struct track track;
	SpotArtist *artist;
  
  //loaded on first prop acces
  SpotAlbum *album;
}
-(id)initWithTrack:(struct track*)track_;

-(NSComparisonResult)compare:(SpotTrack*)other;

//easy access props (loaded on first call)
@property (readonly) SpotAlbum *album;

@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *albumName;
@property (readonly, nonatomic) SpotArtist *artist;
@property (readonly, nonatomic) int length;
@property (readonly, nonatomic) int number;
@property (readonly, nonatomic) float popularity;
@property (readonly, nonatomic) BOOL playable;

@property (readonly, nonatomic) struct track *track;

@property (readonly) SpotId *fileId;
@property (readonly) SpotId *albumId;
@property (readonly) SpotId *coverId;

@property (readonly) UIImage *coverImage;

-(NSUInteger)hash;

@end
