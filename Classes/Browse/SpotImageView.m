//
//  ArtView.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImageView.h"

#import "SpotSession.h"


@implementation SpotImageView

-(void)dealloc;
{
  [artId release];
  [spotImage release];
  [super dealloc];
}

-(NSString*)artId;
{
	return artId;
}

-(void)loadImage;
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [spotImage release]; //view might be reused if we are used in a cell
  spotImage = nil;
  
  if(artId){
    spotImage = [[[SpotSession defaultSession] imageById:artId] retain];
  }
  if(spotImage)
    [self setImage:spotImage.image];
  else
    [self setImage:[UIImage imageNamed:@"icon.png"]]; //default image

  [pool drain];
}

-(void)setArtId:(NSString*)id;
{
  [id retain];
  [artId release];
  artId = id;
  
  //TODO: show spinner while loading!
  [self loadImage];
  //[self performSelectorInBackground:@selector(loadImage) withObject:nil]; //despotify isn't threadsafe OK!
}

@end
