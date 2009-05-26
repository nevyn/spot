//
//  SpotURI.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotURI.h"

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotTrack.h"
#import "SpotPlaylist.h"
#import "SpotSearch.h"

@implementation SpotURI

@synthesize link;

+(SpotURI*)uriWithId:(SpotId*)id;
{
  char uri[50];
  despotify_id2uri(id.id, uri);
  return [SpotURI uriWithURI:uri];
}

+(SpotURI*)uriWithURI:(char *)uri;
{
  return [[[SpotURI alloc] initWithURI:uri] autorelease];
}


-(id)initWithURI:(char*)uri_;
{
  if( ! [super init] ) return nil;
  strcpy(uriBuffer, uri_);
  link = despotify_link_from_uri(uriBuffer);
  
  return self;
}

-(void)dealloc;
{
  despotify_free_link(link);
  [super dealloc];
}

-(SpotLinkType) type;
{
  return link->type;
}

-(NSString *)uri;
{
  return [NSString stringWithCString:link->uri encoding:NSASCIIStringEncoding];
}

-(NSString *)url;
{
  char *typestrings[6] = {
    "",
    "album",
    "artist",
    "playlist",
    "search",
    "track"
  };
  return [NSString stringWithFormat:@"http://open.spotify.com/%s/%s", typestrings[link->type], link->arg];
}

@end
