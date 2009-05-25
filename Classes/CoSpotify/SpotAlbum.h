//
//  SpotAlbum.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "despotify.h"
#import "SpotArtist.h"

@interface SpotAlbum : NSObject {
	struct album album;
}
-(id)initWithAlbum:(struct album*)album;

@property (readonly) NSString *name;
@property (readonly) NSString *artistName;
@property (readonly) UIImage *cover;
@property (readonly) float popularity;
@property (readonly) SpotArtist *artist;
@end
