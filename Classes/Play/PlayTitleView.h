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
	IBOutlet SpotTouchableLabel *artistLabel;
	IBOutlet UILabel *trackLabel;
	IBOutlet SpotTouchableLabel *albumLabel;
}

@property (nonatomic, readonly) UILabel *artistLabel;
@property (nonatomic, readonly) UILabel *trackLabel;
@property (nonatomic, readonly) UILabel *albumLabel;

@end
