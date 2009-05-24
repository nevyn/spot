//
//  SpotArtist.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotArtist.h"


@implementation SpotArtist
-(id)initWithArtist:(struct artist*)artist_;
{
	if( ! [super init] ) return nil;
	
	memcpy(&artist, artist_, sizeof(struct artist));
	
	return self;
}
-(void)dealloc;
{
	[super dealloc];
}

-(NSString*)name;
{
	return [NSString stringWithUTF8String:artist.name];
}
-(float)popularity;
{
	return artist.popularity;
}
-(UIImage*)portrait;
{
	// TODO
	return nil;
}

-(NSString*)description;
{
	return [NSString stringWithFormat:@"<SpotArtist %@>", self.name];
}
@end
