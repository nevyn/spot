//
//  PlayTitleView.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-30.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotTouchableLabel.h"

@interface PlayTitleView : UIView {
	IBOutlet UILabel *artistLabel;
	IBOutlet UILabel *trackLabel;
	IBOutlet UILabel *albumLabel;
  
  id delegate;
}

@property (nonatomic, readonly) UILabel *artistLabel;
@property (nonatomic, readonly) UILabel *trackLabel;
@property (nonatomic, readonly) UILabel *albumLabel;
@property (nonatomic, assign) id delegate;
@end
