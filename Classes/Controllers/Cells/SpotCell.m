//
//  SpotCell.m
//  Spot
//
//  Created by Patrik Sjöberg on 2009-05-29.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpotCell.h"


@implementation SpotCell

@synthesize title, subTitle, bottomTitle, popularity;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
  if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
    //Initialization code
    
    // we need a view to place our labels on.
    UIView *myContentView = self.contentView;
    
    //title
    self.title = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor whiteColor] fontSize:14.0 bold:YES];
    self.title.textAlignment = UITextAlignmentLeft; // default
    [myContentView addSubview:self.title];
    [self.title release];
    
    //subTitle
    self.subTitle = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:12.0 bold:YES];
    self.subTitle.textAlignment = UITextAlignmentLeft; // default
    [myContentView addSubview:self.subTitle];
    [self.subTitle release];
    
    //bottomTitle
    self.bottomTitle = [self newLabelWithPrimaryColor:[UIColor blackColor] selectedColor:[UIColor lightGrayColor] fontSize:10.0 bold:NO];
    self.bottomTitle.textAlignment = UITextAlignmentLeft; // default
    [myContentView addSubview:self.bottomTitle];
    [self.bottomTitle release];
    
    //popularity
    self.popularity = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    [self addSubview:self.popularity];
    self.popularity.progress = 0.5;
    [self.popularity release];
    
    float size = [self bounds].size.height-1;
    spotArt = [[SpotImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [spotArt setImage:[UIImage imageNamed:@"icon.png"]];
    [self addSubview:spotArt];
  }
  return self;
}

-(void)setTitle:(NSString *)t subTitle:(NSString*)s bottomTitle:(NSString *)b popularity:(float)p image:(BOOL)i imageId:(NSString*)ii;
{
  title.text = t;
  subTitle.text = s;
  bottomTitle.text = b;
  popularity.hidden = p < 0.0;
  popularity.progress = p < 0.0 ? 0.5 : p ;//to not go under 0
  spotArt.hidden = !i;
  if(i) self.artId = ii;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
  
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

- (void)layoutSubviews {
  
  [super layoutSubviews];
  
	// getting the cell size
  CGRect selfRect = [self bounds];
  
	// In this example we will never be editing, but this illustrates the appropriate pattern
  if (!self.editing) {
    
		CGRect frame;
    
    float imageWidth = spotArt.bounds.size.width;
    if(spotArt.hidden) imageWidth = 0;
    CGFloat xPos = selfRect.origin.x + imageWidth + 5;

    //title
		frame = CGRectMake(xPos, 4, selfRect.size.width-xPos-40, 20);
		self.title.frame = frame;
    
		//subTitle
		frame = CGRectMake(xPos, frame.origin.y+frame.size.height, selfRect.size.width-xPos-40, 14);
		self.subTitle.frame = frame;
    
    //bottomTitle
		frame = CGRectMake(xPos, frame.origin.y+frame.size.height, selfRect.size.width-xPos-40, 14);
		self.bottomTitle.frame = frame;
    
    //popular?
    frame = CGRectMake(xPos+10, frame.origin.y+frame.size.height+2, selfRect.size.width-xPos-80, self.popularity.bounds.size.height);
    self.popularity.frame = frame;
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
	[subTitle dealloc];
  [spotArt dealloc];
	[super dealloc];
}


@end
