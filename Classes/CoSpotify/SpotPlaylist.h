//
//  SpotPlaylist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "despotify.h"
@class SpotTrack;

@interface SpotPlaylist : NSObject {
	struct playlist playlist;
	NSArray *tracks;
}
-(id)initWithPlaylist:(struct playlist*)playlist_;
-(id)initWithTrack:(SpotTrack*)track;

@property (readwrite, copy) NSString *name;
@property (readonly) NSString *author;
@property (readonly) BOOL collaborative;
@property (readonly) NSArray *tracks;

@end
