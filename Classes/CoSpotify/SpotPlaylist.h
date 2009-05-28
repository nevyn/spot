//
//  SpotPlaylist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
#import "SpotItem.h"
#import "SpotTrackList.h"

@class SpotTrack;
@class SpotId;
@class SpotURI;

@interface SpotPlaylist : SpotItem {
	struct playlist playlist;
  
	SpotTrackList *trackList;
  SpotTrackList *playableTrackList;
  NSString *name;
  NSString *author;
  BOOL collaborative;
  
  SpotId *_id;
  
  BOOL needSorting;
}
-(id)initWithPlaylist:(struct playlist*)playlist_;
-(id)initWithName:(NSString *)name author:(NSString *)author tracks:(NSArray*)tracks;

-(void)setNeedSorting;

@property (readonly, retain) NSString *name;
@property (readonly, nonatomic) NSString *author;
@property (readonly, nonatomic) BOOL collaborative;
@property (readonly, nonatomic) SpotTrackList *trackList;
@property (readonly, nonatomic) SpotTrackList *playableTrackList;

@end

@interface SpotMutablePlaylista : SpotPlaylist {

}

-(void) addTrack:(SpotTrack*)track;

@end