//
//  SpotTrack.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotTrack.h"
#import "xml.h"
#import "SpotSession.h"
#import "SpotURI.h"

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
	//free(track.key);
	[artist release];
	[super dealloc];
}

-(NSComparisonResult)compare:(SpotTrack*)other;
{
  return [self.title compare:other.title];
}

-(int) length; {return track.length;}
-(int) number;{return track.tracknumber;}
-(float) popularity;{return track.popularity;}
-(BOOL) playable;{return track.playable;}


-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotTrack %d. %@>", self.number, self.title];
}

#pragma mark Properties
@synthesize artist;

-(SpotAlbum*)album;
{
  if(album) return album;
  album = [[SpotSession defaultSession] albumById:self.albumId];
  return album;
}

-(NSString*)title;
{
	return [NSString stringWithUTF8String:track.title];
}
-(NSString*)albumName;
{
	return [NSString stringWithUTF8String:track.album];
}


-(struct track*)track;
{
	return &track;
}

-(SpotId *)id; { return [SpotId trackId:(char*)track.track_id]; }

-(SpotURI*)uri;
{
  char uri[50];
  return [SpotURI uriWithURI:despotify_track_to_uri(&track, uri)];  
}

-(SpotId *)fileId; { return [SpotId fileId:(char*)track.file_id]; }

-(SpotId *)albumId; { return [SpotId albumId:(char*)track.album_id]; }
-(SpotId *)coverId; { return [SpotId coverId:(char*)track.cover_id]; }
-(UIImage*)coverImage;
{
  if(self.coverId)
    return [[SpotSession defaultSession] imageById:self.coverId];
  return nil;
}


-(BOOL)isEqual:(SpotTrack*)other;
{
  return [self hash] == [other hash];
}

-(NSUInteger)hash;
{
  return [self.id hash];
}

@end
