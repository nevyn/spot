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

@class SpotTrack;
@class SpotId;
@class SpotURI;

@interface SpotPlaylist : SpotItem {
	struct playlist playlist;
	NSArray *tracks;
}
-(id)initWithPlaylist:(struct playlist*)playlist_;
-(id)initWithTrack:(SpotTrack*)track;

-(SpotTrack*) trackBefore:(SpotTrack*)current;
-(SpotTrack*) trackAfter:(SpotTrack*)current;

-(SpotTrack*) trackWithId:(SpotId*)id;

@property (readwrite, copy) NSString *name;
@property (readonly) NSString *author;
@property (readwrite) BOOL collaborative;
@property (readonly) NSArray *tracks;

@end

@interface SpotMutablePlaylist : SpotPlaylist {

}

-(void) addTrack:(SpotTrack*)track;

@end