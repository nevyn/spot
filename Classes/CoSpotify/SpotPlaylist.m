//
//  SpotPlaylist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-17.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotPlaylist.h"
#import "SpotTrack.h"

@implementation SpotPlaylist
-(id)initWithPlaylist:(struct playlist*)playlist_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&playlist, playlist_, sizeof(struct playlist));
	playlist_->tracks = NULL; // I'll take responsibility for those, thank you very much.
	
	return self;
}
-(void)dealloc;
{
	despotify_free_track(playlist.tracks);
	[super dealloc];
}

-(NSString*)name;
{
	return [NSString stringWithUTF8String:playlist.name];
}
-(void)setName:(NSString*)name_;
{
	//despotify_rename_playlist(ds, playlist, [name_ UTF8String]);
}

-(NSUInteger)countOfTracks;
{
	return playlist.num_tracks;
}
-(SpotTrack*)objectInTracksAtIndex:(NSUInteger)index;
{
	if(index > self.countOfTracks) return nil;
	
	struct track *tr = playlist.tracks;
	for(int i = 0; i != index; i++) {
		tr = tr->next;
	}
	
	return [[[SpotTrack alloc] initWithTrack:tr] autorelease];
}

-(NSArray*)tracks;
{
	return [self valueForKey:@"tracks"];
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotPlaylist %@ %@>", self.name, self.tracks];
}
@end
