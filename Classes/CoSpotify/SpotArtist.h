//
//  SpotArtist.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "despotify.h"

@interface SpotArtist : NSObject {
	struct artist artist;
}
-(id)initWithArtist:(struct artist*)artist;

@property (readonly) NSString *name;
@property (readonly) float popularity;
@property (readonly) UIImage *portrait;
@end
