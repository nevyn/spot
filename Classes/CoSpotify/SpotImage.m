//
//  SpotImage.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotImage.h"


// Put this in UIImageResizing.m
@implementation UIImage (Resizing)

- (UIImage*)scaleToSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), self.CGImage);
	
	UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	return scaledImage;
}

@end



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
  [cellImage release];
  [super dealloc];
}

-(UIImage*)cellImage;
{
  if(!cellImage)
    cellImage = [[self.image scaleToSize:CGSizeMake(70,70)] retain];
  return cellImage;
  //resize to fit a cell
}

-(NSString*)id;
{ return imageId; }

-(NSString *)description;
{
  return [NSString stringWithFormat:@"<SpotImage %@>", imageId];
}

@end
