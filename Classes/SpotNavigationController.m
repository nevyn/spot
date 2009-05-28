//
//  SpotNavigationController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-24.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "SpotNavigationController.h"

#import "AlbumBrowseViewController.h"
#import "ArtistBrowseViewController.h"
#import "SearchViewController.h"
#import "PlayViewController.h"

#import "SpotAppDelegate.h"

#import "SpotArtist.h"
#import "SpotAlbum.h"
#import "SpotSearch.h"

@implementation SpotNavigationController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) return nil;
	
	NSLog(@"Here's a spot navigation controller");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedinNotification:) name:@"loggedin" object:nil];
  
	return self;
}

-(void)dealloc;
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super dealloc];
}

-(void)loggedinNotification:(NSNotification*)n;
{
  if([self checkOpenURL]){
    NSLog(@"how to select searchview?");
  }
}

-(void)showArtist:(SpotArtist*)artist;
{
  [self pushViewController:[[[ArtistBrowseViewController alloc] initBrowsingArtist:artist] autorelease] animated:YES]; 
}

-(void)showAlbum:(SpotAlbum*)album;
{
  [self pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES]; 
}

-(void)showSearch:(SpotSearch*)search;
{
  [self pushViewController:[[[SearchViewController alloc] initWithSearch:search] autorelease] animated:YES]; 
}

-(void)showPlaylists;
{
  
}

-(void)showPlayer;
{
  [self pushViewController:[PlayViewController defaultController] animated:YES];
}

-(BOOL)openURL:(NSURL*)url;
{
  NSLog(@"opening url %@", url);
  SpotURI *uri = [SpotURI uriWithString:[url absoluteString]];
  if(uri){
    SpotSession *session = [SpotSession defaultSession];
    switch(uri.type){
      case SpotLinkTypeArtist:{
        SpotArtist *artist = [session artistByURI:uri];
        [self showArtist:artist];
      }break;
      case SpotLinkTypeAlbum:{
        SpotAlbum *album = [session albumByURI:uri];
        [self showAlbum:album];
      }break;
      case SpotLinkTypeTrack:{
        SpotTrack *track = [session trackByURI:uri];
        [session.player playPlaylist:nil firstTrack:track];
        [self showPlayer];
      }break;
      case SpotLinkTypeSearch:{
        SpotSearch *search = [session searchByURI:uri];
        [self showSearch:search];
      }break;
      case SpotLinkTypePlaylist:{
        SpotPlaylist *pl = [session playlistByURI:uri];
        [session.player playPlaylist:pl firstTrack:nil];
        [self showPlayer];
      }break;
      default:{
        NSLog(@"Invalid uri: %@", uri);
        return NO;
      }break;
    }
    return YES;
  }
  return NO;
}

-(BOOL)checkOpenURL;
{
  //check if we got called by URL
  NSURL *url = ((SpotAppDelegate*)[[UIApplication sharedApplication] delegate]).openURL;
//  url = [NSURL URLWithString:@"http://open.spotify.com/album/74ikOPgco70HHuxrLydWjo"]; //other album
//  url = [NSURL URLWithString:@"http://open.spotify.com/album/6sh0IoRG4pkpDOSCByH5cV"]; //album
//  url = [NSURL URLWithString:@"http://open.spotify.com/track/2QX7lSCOT4OESPUYzvR2wB"]; //track
//  url = [NSURL URLWithString:@"http://open.spotify.com/artist/5K0IAf5mrtln8thyowRn2X"]; //artist
//  url = [NSURL URLWithString:@"http://open.spotify.com/search/mumin"]; //search
//  url = [NSURL URLWithString:@"http://open.spotify.com/user/gujjdo/playlist/1qILpejEO16tlJDGEdX5Yq"]; //playlist
//  url = [NSURL URLWithString:@"spotify:user:gujjdo:playlist:1qILpejEO16tlJDGEdX5Yq"]; //playlist 
  if(url){
    return [self openURL:url];
  }
  return NO;
}

@end
