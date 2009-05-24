//
//  SpotPlaylist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotPlaylist.h"
#import "SpotTrack.h"
#import "SpotSession.h"

@implementation SpotPlaylist
-(id)initWithPlaylist:(struct playlist*)playlist_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&playlist, playlist_, sizeof(struct playlist));
	
	tracks = [[NSMutableArray alloc] initWithCapacity:playlist.num_tracks];
	for(struct track *track = playlist.tracks; track != NULL; track = track->next)
		[(NSMutableArray*)tracks addObject:[[[SpotTrack alloc] initWithTrack:track] autorelease]];
	
	return self;
}
-(void)dealloc;
{
	[tracks release];
	[super dealloc];
}

-(NSString*)name;
{
	return [NSString stringWithUTF8String:playlist.name];
}
-(void)setName:(NSString*)name_;
{
	despotify_rename_playlist([SpotSession defaultSession].session, &playlist, (char*)[name_ UTF8String]);
	// todo: handle error
}

@synthesize tracks;

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotPlaylist %@ %@>", self.name, self.tracks];
}
@end
