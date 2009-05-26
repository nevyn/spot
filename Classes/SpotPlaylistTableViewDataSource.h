//
//  SpotPlaylistTableViewDataSource.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SpotPlaylist;

@interface SpotPlaylistTableViewDataSource : NSObject <UITableViewDataSource> {
  SpotPlaylist *playlist;
}

@property (readwrite, retain) SpotPlaylist *playlist;

-(void)playlistChanged:(NSNotification*)n;

@end
