//
//  ArtView.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SpotId;

@interface SpotImageView : UIImageView {
  SpotId *artId;
}

@property (readwrite, retain) SpotId *artId;

@end
