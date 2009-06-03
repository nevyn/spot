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
  
  UITableViewCellAccessoryType cellAccessoryType;
}

@property (readwrite, retain) SpotPlaylist *playlist;
@property (readwrite, nonatomic) UITableViewCellAccessoryType cellAccessoryType;

-(void)playlistChanged:(NSNotification*)n;

@end
