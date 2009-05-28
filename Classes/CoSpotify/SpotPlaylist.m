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

@implementation SpotPlaylist

-(id)initWithPlaylist:(struct playlist*)playlist_;
{
	if( ! [super init] ) return nil;
  //Create "remote" playlist
  
  if(!playlist_) return nil;
	
  //copy playlist
  memcpy(&playlist, playlist_, sizeof(playlist_));
  
  name = [[NSString alloc] initWithUTF8String:playlist.name];
  author = [[NSString alloc] initWithUTF8String:playlist.author];
  collaborative = playlist.is_collaborative;
  _id = [SpotId playlistId:(char*)playlist.playlist_id];
	
	trackList = [[SpotTrackList alloc] init];
  if(playlist.num_tracks > 0){
    for(struct track *track = playlist.tracks; track != NULL; track = track->next) {
      SpotTrack *strack = [[(SpotTrack*)[SpotTrack alloc] initWithTrack:track] autorelease];
      [trackList addTrack:strack];
    }
  }
  
	return self;
}

-(id)initWithName:(NSString *)name_ author:(NSString *)author_ tracks:(NSArray*)tracks_;
{
  if( ! [super init] ) return nil;
  //Create local playlist
  name = [name_ retain];
  author = [author_ retain];
  trackList = [[SpotTrackList alloc] initWithTracks:tracks_];
  collaborative = NO;
  _id = nil;
  memset(&playlist, 0, sizeof(playlist));
  
  return self;
}

-(void)dealloc;
{
  [_id release];
  [playableTrackList release];
  [author release];
  [name release];
	[trackList release];
	[super dealloc];
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
  if(!_id) return nil;
  char uri[50];
  return [SpotURI uriWithURI:despotify_playlist_to_uri(&playlist, uri)];  
}

-(SpotTrackList*)playableTrackList;
{
  if(playableTrackList) return playableTrackList;
  
  NSMutableArray *pl = [[NSMutableArray alloc] init];
  for(SpotTrack *track in trackList.tracks){
    if(track.playable)
      [pl addObject:track];
  }
  playableTrackList = [[SpotTrackList alloc] initWithTracks:pl];
  return playableTrackList;
}

-(void)setNeedSorting;
{
  needSorting = YES;
}

#pragma mark Properties

@synthesize trackList, playableTrackList, name, author, collaborative;

-(SpotTrackList*)trackList;
{
  if(needSorting){
  }
  needSorting = NO;
  return trackList;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotPlaylist %d %@>", self.name, self.trackList.tracks];
}

@end


@implementation SpotMutablePlaylista

-(void)addTrack:(SpotTrack*)track;
{
  SpotTrack *lastTrack = [trackList.tracks lastObject];
  if(lastTrack)
    lastTrack.track->next = track.track;
  track.track->next = NULL;
  [trackList addTrack:track];
  playlist.num_tracks = [trackList.tracks count];
}

@end

