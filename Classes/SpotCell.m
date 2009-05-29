//
//  SpotCell.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotCell.h"


@implementation SpotCell

@synthesize title, subText;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    //Initialization code
    
    // we need a view to place our labels on.
    UIView *myContentView = self.contentView;
    
    /*
     init the title label.
     set the text alignment to align on the left
     add the label to the subview
     release the memory
     */
    self.title = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
    self.title.textAlignment = UITextAlignmentLeft; // default
    [myContentView addSubview:self.title];
    [self.title release];
    
    /*
     init the url label. (you will see a difference in the font color and size here!
     set the text alignment to align on the left
     add the label to the subview
     release the memory
     */
    self.subText = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
    self.subText.textAlignment = UITextAlignmentLeft; // default
    [myContentView addSubview:self.subText];
    [self.subText release];
    
    float size = [self bounds].size.height;
    spotArt = [[SpotImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [spotArt setImage:[UIImage imageNamed:@"icon.png"]];
    [self addSubview:spotArt];
  }
  return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
  
	// getting the cell size
  CGRect contentRect = self.contentView.bounds;
  
	// In this example we will never be editing, but this illustrates the appropriate pattern
  if (!self.editing) {
    
		// get the X pixel spot
    CGFloat boundsX = contentRect.origin.x;
		CGRect frame;
    
    /*
		 Place the title label.
		 place the label whatever the current X is plus 10 pixels from the left
		 place the label 4 pixels from the top
		 make the label 200 pixels wide
		 make the label 20 pixels high
     */
    float imageWidth = [self bounds].size.height;
		frame = CGRectMake(boundsX + 10 + imageWidth, 4, 200-imageWidth, 20);
		self.title.frame = frame;
    
		// place the url label
		frame = CGRectMake(boundsX + 10 + imageWidth, 28, 200-imageWidth, 14);
		self.subText.frame = frame;
	}
}

/*
 this function was taken from an XML example
 provided by Apple
 
 I can take no credit in this
 */
- (UILabel *)newLabelWithPrimaryColor:(UIColor *)primaryColor selectedColor:(UIColor *)selectedColor fontSize:(CGFloat)fontSize bold:(BOOL)bold
{
	/*
	 Create and configure a label.
	 */
  
  UIFont *font;
  if (bold) {
    font = [UIFont boldSystemFontOfSize:fontSize];
  } else {
    font = [UIFont systemFontOfSize:fontSize];
  }
  
  /*
	 Views are drawn most efficiently when they are opaque and do not have a clear background, so set these defaults.  To show selection properly, however, the views need to be transparent (so that the selection color shows through).  This is handled in setSelected:animated:.
	 */
	UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
	newLabel.backgroundColor = [UIColor whiteColor];
	newLabel.opaque = YES;
	newLabel.textColor = primaryColor;
	newLabel.highlightedTextColor = selectedColor;
	newLabel.font = font;

	return newLabel;
}

- (void)dealloc {
	// make sure you free the memory
	[title dealloc];
	[subText dealloc];
  [spotArt dealloc];
	[super dealloc];
}




@end
