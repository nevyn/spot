//
//  SpotAlbum.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotAlbum.h"


@implementation SpotAlbum

-(id)initWithAlbum:(struct album*)album_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&album, album_, sizeof(struct album));
	
	return self;
}

-(NSString *)name;
{
  return [NSString stringWithCString:album.name];
}

-(NSString *)artistName;
{
  return [NSString stringWithCString:album.artist];
}

-(UIImage *)cover;
{
  //TODO: 
  return nil;
}

-(float)popularity;
{
	return album.popularity;
}

-(SpotArtist *)artist;
{
  //TODO: 
  return nil;
}

@end
