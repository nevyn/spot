//
//  SpotId.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SpotId : NSObject {
  char _id[50];
}
+(SpotId*)trackId:(char[33])id;
+(SpotId*)fileId:(char[41])id;
+(SpotId*)albumId:(char[33])id;
+(SpotId*)coverId:(char[41])id;
+(SpotId*)artistId:(char[33])id;
+(SpotId*)playlistId:(char[35])id;
+(SpotId*)portraitId:(char[41])id;

-(id)initWithId:(char*)id_ size:(char)size;

@property (readonly) char *id;
@property (readonly) char *trackId;
@property (readonly) char *fileId;
@property (readonly) char *albumId;
@property (readonly) char *coverId;
@property (readonly) char *artistId;
@property (readonly) char *playlistId;
@property (readonly) char *portraitId;


@end
