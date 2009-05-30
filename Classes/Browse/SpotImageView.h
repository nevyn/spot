//
//  ArtView.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotImage.h"

@interface SpotImageView : UIImageView {
  NSString *artId;
  SpotImage *spotImage;
  UIActivityIndicatorView *activityView;
}

@property (readwrite, retain) NSString *artId;

@end
