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
-(void)setArtId:(SpotId*)id;
{
  [id retain];
  [artId release];
  artId = id;
  
  //TODO: async and with spinner while loading!
  UIImage *image = [[SpotSession defaultSession] imageById:artId];
  if(image) [self setImage:image];
}

@end
