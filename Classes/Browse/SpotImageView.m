//
//  ArtView.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImageView.h"

#import "SpotSession.h"

@interface SpotImageView ()

-(void)setSpotImage:(SpotImage*)img;

@end


@implementation SpotImageView

-(id)initWithFrame:(CGRect)frame;
{
  if(![super initWithFrame:frame]) return nil;
  NSLog(@"imageview init");
  
  activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
  [self addSubview:activityView];
  [activityView setHidden:NO];
  activityView.hidesWhenStopped = YES;
  
  return self;
}

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

-(void)setSpotImage:(SpotImage*)img;
{
  [img retain];
  [spotImage release];
  spotImage = img;
  if(spotImage)
    [self setImage:spotImage.image];
  else
    [self setImage:[UIImage imageNamed:@"icon.png"]]; //default image  
  [activityView stopAnimating];
}

-(void)loadImage;
{
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  [spotImage release]; //view might be reused if we are used in a cell
  spotImage = nil;
  
  if(artId){
    //check the cache to see if we might have the image loaded allready (so we dont need to bother the session thread for nothing)
    SpotImage *cachedImage = (SpotImage*)[[SpotSession defaultSession] cachedItemById:artId];
    if(cachedImage){
      [self setSpotImage:cachedImage];
    } else {
      //Load image
      [activityView startAnimating];
      [[SpotSession defaultSession] asyncImageById:artId respondTo:self selector:@selector(setSpotImage:)];
    }
  }

  [pool drain];
}

-(void)setArtId:(NSString*)id;
{
  if(![artId isEqual:id]){
    [id retain];
    [artId release];
    artId = id;
    //default image while loading
    [self setImage:[UIImage imageNamed:@"icon.png"]];
    if(artId){
      //Begin load image
      [self loadImage];
    }
  } 
}

@end
