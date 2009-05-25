//
//  SpotTrack.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotTrack.h"
#import "xml.h"
#import "SpotPlaylist.h"

@implementation SpotTrack
-(id)initWithTrack:(struct track*)track_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&track, track_, sizeof(struct track));
	track.key = NULL; // I don't own the memory it points to and I don't need it right now
	
	artist = [[SpotArtist alloc] initWithArtist:track.artist];
	
	return self;
}
-(void)dealloc;
{
	free(track.key);
	[artist release];
	[super dealloc];
}

@synthesize playlist;

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

-(int) length; {return track.length;}
-(int) number;{return track.tracknumber;}
-(float) popularity;{return track.popularity;}
-(BOOL) playable;{return track.playable;}


-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotTrack %@>", self.title];
}

-(struct track*)track;
{
	return &track;
}

-(SpotId *)id; { return [SpotId trackId:track.track_id]; }

-(SpotId *)fileId; { return [SpotId fileId:track.file_id]; }

-(SpotId *)albumId; { return [SpotId albumId:track.album_id]; }
-(SpotId *)coverId; { return [SpotId coverId:track.cover_id]; }

@end
