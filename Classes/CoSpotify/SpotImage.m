//
//  SpotImage.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImage.h"


@implementation SpotImage

@synthesize image;

-(id)initWithImageData:(NSData *)data id:(NSString*)id_;
{
  if( ! [super init] ) return nil;
  
  imageId = [id_ retain];
  image = [[UIImage alloc] initWithData:data];
  if(!image){
    [self release];
    return nil;
  }
  
  return self;
}

-(void)dealloc;
{
  [imageId release];
  [image release];
  [super dealloc];
}

-(NSString*)id;
{ return imageId; }

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotImage %@>", imageId];
}

@end
