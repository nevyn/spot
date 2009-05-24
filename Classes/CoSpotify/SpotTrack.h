//
//  SpotTrack.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
#import "SpotArtist.h"
@class SpotPlaylist;
@interface SpotTrack : NSObject {
	struct track track;
	SpotArtist *artist;
	SpotPlaylist *playlist;
}
-(id)initWithTrack:(struct track*)track_;

@property (readonly, nonatomic) NSString *title;
@property (readonly, nonatomic) NSString *albumName;
@property (readonly, nonatomic) SpotArtist *artist;

@property (readonly, nonatomic) struct track *track;
@property (readwrite, assign, nonatomic) SpotPlaylist *playlist;
@end
