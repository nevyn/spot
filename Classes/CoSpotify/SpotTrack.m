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
	[trackId release];
  [title release];
  [artistId release];
  [artistName release];
  [albumName release];
  [albumId release];
  [coverId release];
  [similarTrackIds release];
  [files release];
  [restrictions release];
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

#pragma mark NSCoding

-(id)initWithCoder:(NSCoder *)decoder;
{
  //struct track de_track; //we need a struct to send to despotify
  
  trackId = [[decoder decodeObjectForKey:@"Tid"] retain];
  title = [[decoder decodeObjectForKey:@"Ttitle"] retain];
  artistId = [[decoder decodeObjectForKey:@"TartistId"] retain];
  artistName = [[decoder decodeObjectForKey:@"TartistName"] retain];
  albumName = [[decoder decodeObjectForKey:@"TalbumName"] retain];
  albumId = [[decoder decodeObjectForKey:@"TalbumId"] retain];
  coverId = [[decoder decodeObjectForKey:@"TcoverId"] retain];
  similarTrackIds = [[decoder decodeObjectForKey:@"Tsimilar"] retain];
  files = [[decoder decodeObjectForKey:@"Tfiles"] retain];
  restrictions = [[decoder decodeObjectForKey:@"Trestrictions"] retain];
  
  trackNumber = [decoder decodeIntForKey:@"TtrackNumber"];
  year = [decoder decodeIntForKey:@"Tyear"];
  length = [decoder decodeFloatForKey:@"Tlength"];
  popularity = [decoder decodeFloatForKey:@"Tpopularity"];
  

  isPlayable = [decoder decodeBoolForKey:@"Tplayable"];
  hasMetadata = [decoder decodeBoolForKey:@"ThasMeta"];
  return self;
}

-(void)encodeWithCoder:(NSCoder *)encoder;
{
  [encoder encodeObject:trackId forKey:@"Tid"];
  [encoder encodeObject:title forKey:@"Ttitle"];
  [encoder encodeObject:artistId forKey:@"TartistId"];
  [encoder encodeObject:artistName forKey:@"TartistName"];
  [encoder encodeObject:albumName forKey:@"TalbumName"];
  [encoder encodeObject:albumId forKey:@"TalbumId"];
  [encoder encodeObject:coverId forKey:@"TcoverId"];
  [encoder encodeObject:similarTrackIds forKey:@"Tsimilar"];
  [encoder encodeObject:files forKey:@"Tfiles"];
  [encoder encodeObject:restrictions forKey:@"Trestrictions"];
  [encoder encodeInt:trackNumber forKey:@"TtrackNumber"];
  [encoder encodeInt:year forKey:@"Tyear"];
  [encoder encodeFloat:length forKey:@"Tlength"];
  [encoder encodeFloat:popularity forKey:@"Tpopularity"];
  [encoder encodeBool:isPlayable forKey:@"Tplayable"];
  [encoder encodeBool:hasMetadata forKey:@"ThasMeta"];
  
}

@end
