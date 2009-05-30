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
-(void)showPlayer:(id)sender;{[self showPlayer];}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil] ) return nil;
	
	NSLog(@"Here's a spot navigation controller");
  
	return self;
}

-(void)dealloc;
{
  [super dealloc];
}

-(void)viewDidLoad;
{
  
}


-(void)setArrowBackButton;
{
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                 initWithImage:[UIImage imageNamed:@"arrow-left.png"]
                                 style:UIBarButtonItemStyleBordered 
                                 target:nil 
                                 action:nil];
  
  UIViewController *current = self.topViewController;
	current.navigationItem.backBarButtonItem = backButton;
  [backButton release];
}

-(void)setDefaultBackButton;
{
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] 
                                 initWithTitle:[self.topViewController.navigationItem.backBarButtonItem.possibleTitles anyObject]
                                 style:UIBarButtonItemStyleBordered 
                                 target:nil 
                                 action:nil];
  
  UIViewController *current = self.topViewController;
	current.navigationItem.backBarButtonItem = backButton;
  [backButton release];  
}

- (void)pushNavigationItem:(UIViewController *)item animated:(BOOL)animated;
{
  [super pushViewController:item animated:animated];
}

-(void)showArtist:(SpotArtist*)artist;
{
  [self setDefaultBackButton];
  [self pushViewController:[[[ArtistBrowseViewController alloc] initBrowsingArtist:artist] autorelease] animated:YES]; 
}

-(void)showAlbum:(SpotAlbum*)album;
{
  [self setDefaultBackButton];
  [self pushViewController:[[[AlbumBrowseViewController alloc] initBrowsingAlbum:album] autorelease] animated:YES]; 
}

-(void)showSearch:(SpotSearch*)search;
{
  [self setDefaultBackButton];
  [self pushViewController:[[[SearchViewController alloc] initWithSearch:search] autorelease] animated:YES]; 
}

-(void)showPlaylists;
{
  
}


-(void)showPlayer;
{
  
  [self setArrowBackButton];
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

@end
