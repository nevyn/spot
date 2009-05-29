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
#import "SpotURI.h"

@implementation SpotTrackSlot

@synthesize track, playlist, position;

-(id)initWithPlaylist:(SpotPlaylist *)p track:(SpotTrack*)t position:(NSInteger)pos;
{
  if( ! [super init] ) return nil;
  
  playlist = [p retain];
  track = [t retain];
  position = pos;
  
  return self;
}

-(void)dealloc;
{
  [playlist release];
  [track release];
  [super dealloc];
}

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotTrackSlot pos: %d. track: %@>", position, track];
}
@end


@implementation SpotPlaylist

-(id)initWithPlaylist:(struct playlist*)playlist;
{
	if( ! [super init] ) return nil;
  //Create "remote" playlist
  
  name = [[NSString alloc] initWithUTF8String:playlist->name];
  author = [[NSString alloc] initWithUTF8String:playlist->author];
  playlistId = [[NSString alloc] initWithCString:(const char*)playlist->playlist_id encoding:NSASCIIStringEncoding];
  collaborative = playlist->is_collaborative;
  revision = playlist->revision;
  checksum = playlist->checksum;
  
  slots = [[NSMutableArray alloc] init];
  for(struct track *track = playlist->tracks; track != NULL; track = track->next){
    SpotTrack *a_track = [[SpotTrack alloc] initWithTrack:track];
    SpotTrackSlot *slot = [[SpotTrackSlot alloc] initWithPlaylist:self track:a_track position:[slots count]];
    [slots addObject:slot];
    [slot release];
    [a_track release];
  }
    
	return self;
}

-(id)initWithName:(NSString *)name_ author:(NSString *)author_ tracks:(NSArray*)tracks_;
{
  if( ! [super init] ) return nil;
  //Create local playlist
  name = [name_ retain];
  author = [author_ retain];
  
  slots = [[NSMutableArray alloc] init];
  for(SpotTrack *track in tracks_){
    SpotTrackSlot *slot = [[SpotTrackSlot alloc] initWithPlaylist:self track:track position:[slots count]];
    [slots addObject:slot];
    [slot release];
  }
  
  return self;
}

-(void)dealloc;
{
  [playlistId release];
  [author release];
  [name release];
	[slots release];
	[super dealloc];
}

-(SpotTrack*) trackBefore:(SpotTrack*)track;
{
  NSInteger idx = [self positionOfTrack:track];
  if(idx == NSNotFound) return nil;
  idx -= 1;
  if(idx < 0) return nil;
  return [self trackAtPosition:idx];
}

-(SpotTrack*) trackAfter:(SpotTrack*)track;
{
  NSInteger idx = [self positionOfTrack:track];
  if(idx == NSNotFound) return nil;
  idx += 1;
  if(idx >= [self tracks].count) return nil;
  return [self trackAtPosition:idx];  
}

-(NSInteger) positionOfTrack:(SpotTrack*)track;
{
  //TODO: this is ugly version. make slots hash/compare (whatever nsarray use to find object) equal to tracks
  for(NSInteger i = 0; i < slots.count; i++){
    SpotTrackSlot *slot = [slots objectAtIndex:i];
    if([slot.track isEqual:track]) return i;
  }
  return NSNotFound;
}

-(SpotTrack *) trackAtPosition:(NSInteger)position;
{
  SpotTrackSlot *slot = [slots objectAtIndex:position];
  return slot.track;
}


-(BOOL)isEqual:(SpotPlaylist*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [[NSString stringWithFormat:@"%@%@", self.author, self.name] hash];
}

-(SpotURI*)uri;
{
/*  if(!_id) return nil;
  char uri[50];
  return [SpotURI uriWithURI:despotify_playlist_to_uri(&playlist, uri)];  
 */
  return nil;
}

#pragma mark Properties

@synthesize tracks, name, author, collaborative;

-(NSArray*)tracks;
{
  //TODO: cache tracklist
  NSMutableArray *t = [NSMutableArray array];
  for(SpotTrackSlot *slot in slots){
    [t addObject:slot.track];
  }
  return t;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotPlaylist %d tracks: %@>", self.name, self.tracks];
}

@end


@implementation SpotMutablePlaylista

-(void)addTrack:(SpotTrack*)track;
{
  SpotTrackSlot *slot = [[SpotTrackSlot alloc] initWithPlaylist:self track:track position:[slots count]];
  [slots addObject:slot];
  [slot release];
}

@end

