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

@interface SpotTrack : NSObject {
	struct track track;
	SpotArtist *artist;
}
-(id)initWithTrack:(struct track*)track_;

@property (readonly) NSString *title;
@property (readonly) NSString *albumName;
@property (readonly) SpotArtist *artist;
@end
