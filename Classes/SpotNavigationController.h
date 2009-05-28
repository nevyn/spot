//
//  SpotNavigationController.h
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SpotArtist;
@class SpotAlbum;
@class SpotSearch;


@interface SpotNavigationController : UINavigationController {

}

-(void)loggedinNotification:(NSNotification*)n;
-(BOOL)checkOpenURL;
-(BOOL)openURL:(NSURL*)url;

-(void)showArtist:(SpotArtist*)artist;
-(void)showAlbum:(SpotAlbum*)album;
-(void)showSearch:(SpotSearch*)search;
-(void)showPlaylists;
-(void)showPlayer;

@end

@interface UINavigationController (SpotNav)

-(void)showArtist:(SpotArtist*)artist;
-(void)showAlbum:(SpotAlbum*)album;
-(void)showSearch:(SpotSearch*)search;
-(void)showPlaylists;
-(void)showPlayer;
-(BOOL)checkOpenURL;
-(BOOL)openURL:(NSURL*)url;

@end
