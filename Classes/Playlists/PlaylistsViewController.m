//
//  RootViewController.m
//  Spot
//
//  Created by Joachim Bengtsson on 2009-05-16.
//  Copyright Third Cog Software 2009. All rights reserved.
//

#import "PlaylistsViewController.h"
#import "SpotNavigationController.h"
#import "CoSpotify.h"
#import "SpotCell.h"

@implementation PlaylistsViewController
-(id)init;
{
	if(![super initWithNibName:@"PlaylistsView" bundle:nil]) return nil;
	
	self.title = @"Playlists";
	self.tabBarItem.image = [UIImage imageNamed:@"playlists.png"]; // from http://glyphish.com/ yay!
	
	return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  tableView = (UITableView*)self.view;
	tableView.rowHeight = 70;
  
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}

-(NSArray*)playlists;
{
	if(!playlists)
		playlists = [[[SpotSession defaultSession] playlists] retain];
	return playlists;
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if( ! [SpotSession defaultSession].loggedIn) return 1;
	
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if( ! [SpotSession defaultSession].loggedIn) return 0;
	
    return self.playlists.count;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{

  int idx = [indexPath indexAtPosition:1];
	SpotPlaylist *playlist = [self.playlists objectAtIndex:idx];
  
  static NSString *SpotCellIdentifier = @"SpotCell";
  
  SpotCell *cell = (SpotCell *)[tableView dequeueReusableCellWithIdentifier:SpotCellIdentifier];
  if (cell == nil) 
    cell = [[[SpotCell alloc] initWithFrame:CGRectZero reuseIdentifier:SpotCellIdentifier] autorelease];
  	
  float totalTime = 0;
  for(SpotTrack *t in playlist.tracks)
    totalTime += t.length;
  
  //TODO: some nice way to show collaborative status
  [cell setTitle:playlist.name 
        subTitle:playlist.author 
     bottomTitle:[NSString stringWithFormat:@"%.2f hours in %d tracks", totalTime/60.0/60.0, [playlist.tracks count]]
      popularity:-1 
           image:NO 
         imageId:nil];

  return cell;
}




// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
  int idx = [indexPath indexAtPosition:1];
  SpotPlaylist *playlist = [self.playlists objectAtIndex:idx];
  [[SpotSession defaultSession].player playPlaylist:playlist firstTrack:nil];
  [self.navigationController showPlayer];
    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[playlists release];
    [super dealloc];
}


@end

