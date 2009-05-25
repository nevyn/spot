//
//  SpotSearch.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotSearch.h"
#import "SpotTrack.h"
#import "SpotAlbum.h"
#import "SpotArtist.h"


@implementation SpotSearch

@synthesize tracks, artists, albums, playlist, suggestion, query;
@synthesize totalTracks, totalArtists, totalAlbums;

+(SpotSearch *)searchFor:(NSString *)searchText session:(SpotSession*)session maxResults:(int)maxResults;
{
  return [[[SpotSearch alloc] initWithSearchText:searchText session:session maxResults:maxResults] autorelease];
}

+(SpotSearch *)searchFor:(NSString *)searchText maxResults:(int)maxResults;
{
  return [SpotSearch searchFor:searchText session:[SpotSession defaultSession] maxResults:maxResults];
}

-(id)initWithSearchText:(NSString *)searchText session:(SpotSession*)session maxResults:(int)maxResults;
{
  if( ! [super init] ) return nil;
  if(searchResult){
    despotify_free_search(searchResult);
  }
  searchResult = despotify_search(session.session, (char*)[searchText UTF8String], maxResults);
  [self initWithSearchResult:searchResult];
  
  return self;
}

-(id)initWithSearchResult:(struct search_result*)sr;
{
	if( ! [super init] ) return nil;
  
  if( ! sr ) return nil;
  
  playlist = [[SpotPlaylist alloc] initWithPlaylist:sr->playlist];
  
  query = [[NSString alloc] initWithCString:(char*)sr->query];
  if(sr->suggestion[0] != '\0')
    suggestion = [[NSString alloc] initWithCString:(char*)sr->suggestion];
  else suggestion = nil;
  
  totalAlbums = sr->total_albums;
  totalTracks = sr->total_tracks;
  totalArtists = sr->total_artists;
  
  NSMutableArray *a_tracks = [[NSMutableArray alloc] init];
  if(totalTracks > 0){
    for(struct track *track = sr->tracks; track != NULL; track = track->next){
      [a_tracks addObject:[[[SpotTrack alloc] initWithTrack:track] autorelease]];
    }
  }
  tracks = a_tracks;
  
  NSMutableArray *a_artists = [[NSMutableArray alloc] init];
  if(totalArtists > 0){
    for(struct artist *artist = sr->artists; artist != NULL; artist = artist->next){
      [a_artists addObject:[[[SpotArtist alloc] initWithArtist:artist] autorelease]];
    }
  }
  artists = a_artists;
  

  NSMutableArray *a_albums = [[NSMutableArray alloc] init];
  if(totalAlbums > 0){
    for(struct album *album = sr->albums; album != NULL; album = album->next){
      [a_albums addObject:[[[SpotAlbum alloc] initWithAlbum:album] autorelease]];
    }
  }
  albums = a_albums;
  
  return self;
}


-(void) dealloc;
{
  despotify_free_search(searchResult);
  [playlist release];
  [suggestion release];
  [query release];
  [tracks release];
  [albums release];
  [artists release];
  [super dealloc];
}


-(NSString *)description;
{
  return [NSString stringWithFormat:@"Search for %@ found %d tracks %d albums and %d artists", query, totalTracks, totalAlbums, totalArtists];
}

-(SpotSearch *)moreResults;
{
  int offset = 0;
  struct search_result *sr = despotify_search_more(session.session, searchResult, offset, maxResults);
  if( !sr ) return nil;
  return [[[SpotSearch alloc] initWithSearchResult:sr] autorelease];
}

@end
