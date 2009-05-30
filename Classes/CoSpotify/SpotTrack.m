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

@synthesize trackId, title, artistId, artistName, albumName, albumId, coverId, trackNumber, length, files, popularity, similarTrackIds, restrictions, year, isPlayable;

@synthesize album, artist;


-(id)initWithTrack:(struct track*)track;
{
	if( ! [super init] ) return nil;
  
  memcpy(&de_track, track, sizeof(struct track));
	
  hasMetadata = track->has_meta_data;
  isPlayable = track->playable;
  trackId = [[NSString alloc] initWithUTF8String:(char*)track->track_id];
  files = nil;
  albumId = [[NSString alloc] initWithUTF8String:(char*)track->album_id];
  coverId = [[NSString alloc] initWithUTF8String:(char*)track->cover_id];
  title = [[NSString alloc] initWithUTF8String:track->title];
  albumName = [[NSString alloc] initWithUTF8String:track->album];
  length = track->length/1000.0;
  trackNumber = track->tracknumber;
  year = track->year;
  popularity = track->popularity;
	
	artist = [[SpotArtist alloc] initWithArtist:track->artist];
	
	return self;
}

-(void)dealloc;
{
	//free(track.key);
	[artist release];
  [album release];
	[super dealloc];
}

-(NSComparisonResult)compare:(SpotTrack*)other;
{
  return [self.title compare:other.title];
}



-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotTrack %d. %@>", self.trackNumber, self.title];
}

#pragma mark Properties



-(struct track*)track;
{
	return &de_track;
}

-(NSString *)id; { return trackId; }

-(SpotURI*)uri;
{
  char uri[50];
  return [SpotURI uriWithURI:despotify_track_to_uri(&de_track, uri)];  
}

-(UIImage*)coverImage;
{
  if(self.coverId)
    return [[SpotSession defaultSession] imageById:coverId];
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


-(SpotAlbum*)album;
{
  if(album) return album;
  album = [[[SpotSession defaultSession] albumById:albumId] retain];
  return album;
}


-(struct track*)de_track;
{
  return &de_track;
}

@end
