//
//  SpotSearch.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotPlaylist.h"
#import "SpotSession.h"

#import "despotify.h"
#import "SpotItem.h"

@interface SpotSearch : SpotItem { 
  NSArray *artists;
  NSArray *tracks;
  NSArray *albums;
  NSString *query;
  NSString *suggestion;
  int totalTracks;
  int totalArtists;
  int totalAlbums;

  //for -moreResults
  SpotSession *session;
  int maxResults;
  struct search_result *searchResult;
}

+(SpotSearch *)searchFor:(NSString *)searchText session:(SpotSession*)session maxResults:(int)maxResults;
+(SpotSearch *)searchFor:(NSString *)searchText maxResults:(int)maxResults;

-(id)initWithSearchText:(NSString *)searchText session:(SpotSession*)session maxResults:(int)maxResults;
-(id)initWithSearchResult:(struct search_result*)sr;

//Get next batch of results
-(SpotSearch *)moreResults;

@property (readonly, nonatomic) NSArray *tracks;
@property (readonly, nonatomic) NSArray *artists;
@property (readonly, nonatomic) NSArray *albums;
@property (readonly, nonatomic) int totalTracks;
@property (readonly, nonatomic) int totalArtists;
@property (readonly, nonatomic) int totalAlbums;
@property (readonly, nonatomic) NSString *suggestion;
@property (readonly, nonatomic) NSString *query;

@end
