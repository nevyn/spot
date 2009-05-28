//
//  ArtView.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImageView.h"

#import "SpotSession.h"
#import "SpotId.h"

@implementation SpotImageView
-(SpotId*)artId;
{
	return artId;
}

-(void)loadImage;
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  UIImage *image = nil;
  if(artId){
    image = [[SpotSession defaultSession] imageById:artId];
  }
  if(image) [self setImage:image];
  [pool drain];
}

-(void)setArtId:(SpotId*)id;
{
  [id retain];
  [artId release];
  artId = id;
  
  [self setImage:[UIImage imageNamed:@"icon.png"]];
  //TODO: show spinner while loading!
  [self loadImage];
  
  //[self performSelectorInBackground:@selector(loadImage) withObject:nil]; //despotify isn't threadsafe OK!
}

@end
