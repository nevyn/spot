//
//  SpotTrack.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotTrack.h"
#import "xml.h"


@implementation SpotTrack
-(id)initWithTrack:(struct track*)track_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&track, track_, sizeof(struct track));
	// I assume responsibility for these:
	track_->key = NULL;
	
	artist = [[SpotArtist alloc] initWithArtist:track.artist];
	
	return self;
}
-(void)dealloc;
{
	free(track.key);
	[artist release];
	[super dealloc];
}

-(NSString*)title;
{
	return [NSString stringWithUTF8String:track.title];
}
-(NSString*)albumName;
{
	return [NSString stringWithUTF8String:track.album];
}
-(SpotArtist*)artist;
{
	return artist;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotTrack %@>", self.title];
}
@end
