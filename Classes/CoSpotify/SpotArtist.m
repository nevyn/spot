//
//  SpotArtist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotId.h"
#import "SpotSession.h"
#import "SpotURI.h"



@implementation SpotArtistBio

@synthesize text, portraits;

-(id)initWithText:(NSString*)t;
{
  if( ! [super init] ) return nil;
  
  text = [t retain];
  
  return self;
}

-(void)dealloc;
{
  [text release];
  [portraits release];
  [super dealloc];
}

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotArtistBio text: %@ portraits: %@>", text, portraits];
}

@end




@implementation SpotArtist

@synthesize browsing;
@synthesize name, portraitId, popularity, version, artistId, bios, similarArtists, genres, yearsActive, albums;


-(id)initWithArtist:(struct artist*)artist;
{
	if( ! [super init] ) return nil;
  
  browsing = NO;
	
  name = [[NSString alloc] initWithUTF8String:artist->name];
  artistId = [[NSString alloc] initWithUTF8String:artist->id];
  portraitId = [[NSString alloc] initWithUTF8String:artist->portrait_id];
  popularity = artist->popularity;
  
	return self;
}

-(void)loadBrowse:(struct artist_browse*)artist;
{
  browsing = YES;
	
  SpotArtistBio *bio = [[SpotArtistBio alloc] initWithText:[NSString stringWithUTF8String:artist->text]];
  bios = [[NSArray alloc] initWithObjects:bio, nil];
  [bio release];
  
  NSMutableArray *a_albums = [[NSMutableArray alloc] initWithCapacity:artist->num_albums];
  if(artist->num_albums > 0){
    for(struct album_browse *album = artist->albums; album != NULL; album = album->next){
      [a_albums addObject:[[[SpotAlbum alloc] initWithAlbumBrowse:album] autorelease]];
    }
  }
  albums = a_albums;  
}

-(id)initWithArtistBrowse:(struct artist_browse*)artistBrowse_;
{
	if( ! [super init] ) return nil;
  
  [self loadBrowse:artistBrowse_];
  
	return self;
}

-(void)dealloc;
{
	[super dealloc];
}

-(void)loadMoreInfo;
{
  if(!browsing){
    NSLog(@"Artist %@ loading more info", self);
    struct artist_browse *ab = despotify_get_artist([SpotSession defaultSession].session, (char*)[artistId UTF8String]);
    [self loadBrowse:ab];
  }
}

-(NSComparisonResult)compare:(SpotArtist*)other;
{
  return [self.name compare:other.name];
}

#pragma mark Properties

-(SpotId *)id;
{
  return [SpotId artistId:(char*)[artistId UTF8String]];
}

-(SpotURI*)uri;
{
  //char uri[50];
  //return [SpotURI uriWithURI:despotify_artist_to_uri(&artistBrowse, uri)];  
  return nil;
}


-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotArtist %@>", self.name];
}

#pragma mark props form _browse

-(NSArray *)albums;
{
  if(!browsing) [self loadMoreInfo];
  return albums;
}


-(NSString *)text;
{
  if(!browsing) [self loadMoreInfo];
  if(!bios || [bios count] == 0) return @"";
  return ((SpotArtistBio*)[bios lastObject]).text;
}

-(BOOL)isEqual:(SpotArtist*)other;
{
  return [self hash] == [other hash];
}

-(NSInteger)hash;
{
  return [self.id hash];
}

@end
