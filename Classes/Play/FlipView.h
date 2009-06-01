//
//  FlipView.h
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FlipView : UIView {
  CGPoint swipeStart;
}

-(IBAction)flip;
-(void)flipWithUIViewAnimation:(NSInteger)anim;

@end
