//
//  RadiusControl.m
//  MAPCONTROL
//
//  Created by Andreas Kompanez on 24.07.10.
//  Copyright 2010 Endless Numbered. All rights reserved.
//

#import "RadiusControl.h"

#import <QuartzCore/QuartzCore.h>
#import "UIColor+Hex.h"

static const CGFloat kRadiusControlExpandedWidth = 300.0f;
static const CGFloat kRadiusControlNotExpandedWidth = 115.0f;

static const NSUInteger kRadiusControlFirstSubviewButton = 1;
static const NSUInteger kRadiusControlSecondSubviewButton = 2;
static const NSUInteger kRadiusControlThirdSubviewButton = 3;
static const NSUInteger kRadiusControlFourthSubviewButton = 4;

@interface RadiusControl ()

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isAnimating) BOOL animating;
@property (nonatomic, assign) CGPoint notExpandedCenterPoint;

@property (nonatomic, retain) RadiusControlSubviewWithLabel *firstSubview;
@property (nonatomic, retain) RadiusControlSubviewWithLabel *secondSubview;
@property (nonatomic, retain) RadiusControlSubviewWithLabel *thirdSubview;
@property (nonatomic, retain) RadiusControlSubview *fourthSubview;

@property (nonatomic, retain) RadiusControlSubview *currentSelectedView;

@property (nonatomic, assign) RadiusControlValue selectedValue;

@property (nonatomic, retain) NSTimer *hideControlTimer;


- (void)_initControl;

- (void)_toogleSize;

- (void)_onFirstButton:(id)sender;
- (void)_onSecondButton:(id)sender;
- (void)_onThirdButton:(id)sender;
- (void)_onFourthButton:(id)sender;

- (void)_handleExpandingAnimation;
- (void)_expandingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;


- (void)_handleDecreasingAnimation;
- (void)_startViewSizeDecreasingAnimation;
- (void)_decreasingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void)_destroyHideControlTimer;

@end

@implementation RadiusControl

@synthesize expanded = _expanded;
@synthesize label = _label;
@synthesize notExpandedCenterPoint = _notExpandedCenterPoint;
@synthesize refreshButtonView = _refreshButtonView;
@synthesize animating = _animating;
@synthesize firstSubview = _firstSubview;
@synthesize secondSubview = _secondSubview;
@synthesize thirdSubview = _thirdSubview;
@synthesize fourthSubview = _fourthSubview;
@synthesize selectedValue = _selectedValue;
@synthesize currentSelectedView = _currentSelectedView;
@synthesize hideControlTimer = _hideControlTimer;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		[self _initControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self != nil) {
		[self _initControl];
	}
	return self;
}

#pragma mark -

- (void)fillRoundedRect:(CGRect)rect inContext:(CGContextRef)context
{
    float radius = 5.0f;
    
    CGContextBeginPath(context);
	CGContextSetGrayFillColor(context, 0.8, 0.5);
	CGContextMoveToPoint(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect));
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMinY(rect) + radius, radius, 3 * M_PI / 2, 0, 0);
    CGContextAddArc(context, CGRectGetMaxX(rect) - radius, CGRectGetMaxY(rect) - radius, radius, 0, M_PI / 2, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMaxY(rect) - radius, radius, M_PI / 2, M_PI, 0);
    CGContextAddArc(context, CGRectGetMinX(rect) + radius, CGRectGetMinY(rect) + radius, radius, M_PI, 3 * M_PI / 2, 0);
	
    CGContextClosePath(context);
    CGContextFillPath(context);
}

- (void)drawRect:(CGRect)rect
{
	// draw a box with rounded corners to fill the view -
	CGRect boxRect = self.bounds;
    CGContextRef ctxt = UIGraphicsGetCurrentContext();	
	boxRect = CGRectInset(boxRect, 1.0f, 1.0f);
    [self fillRoundedRect:boxRect inContext:ctxt];
}

#pragma mark -

- (void)onRefreshAction:(id)sender
{
	if (NO == self.isExpanded) {
		return;
	}
	[self performSelector:@selector(_handleDecreasingAnimation) withObject:nil afterDelay:0.1];
}


#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self _toogleSize];
	[super touchesEnded:touches withEvent:event];
}

#pragma mark -
#pragma mark Private methods

- (void)_onFirstButton:(id)sender
{	
	self.selectedValue = RadiusControlValueFirst;
	[self _toogleSize];
}

- (void)_onSecondButton:(id)sender
{	
	self.selectedValue = RadiusControlValueSecond;
	[self _toogleSize];
}

- (void)_onThirdButton:(id)sender
{	
	self.selectedValue = RadiusControlValueThird;
	[self _toogleSize];
}

- (void)_onFourthButton:(id)sender
{	
	self.selectedValue = RadiusControlValueFourth;
	[self _toogleSize];
}

#pragma mark -
#pragma mark Expanding

- (void)_handleExpandingAnimation
{
	if (self.isAnimating) {
		return;
	}
	
	CGFloat height = self.bounds.size.height;
	
	self.animating = YES;
	self.userInteractionEnabled = NO;
	
	
	
	[self.currentSelectedView removeFromSuperview];
	self.currentSelectedView = nil;
	
	
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.5f];
	[UIView setAnimationDidStopSelector:@selector(_expandingAnimationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, kRadiusControlExpandedWidth, height);
	self.center = CGPointMake(self.notExpandedCenterPoint.x + ((kRadiusControlExpandedWidth - kRadiusControlNotExpandedWidth)/2), self.center.y);
	[UIView commitAnimations];
}

- (void)_expandingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{	
	[UIView beginAnimations:nil context:nil];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationDidStopSelector:@selector(_showSubviewsAnimationDidStop:finished:context:)];
	self.refreshButtonView.alpha = 1.0;
	
	self.firstSubview.alpha = 1.0;
	self.secondSubview.alpha = 1.0;
	self.thirdSubview.alpha = 1.0;
	self.fourthSubview.alpha = 1.0;
	
	if (self.selectedValue == RadiusControlValueFirst) {
		self.firstSubview.selected = YES;
		self.secondSubview.selected = NO;
		self.thirdSubview.selected = NO;
		self.fourthSubview.selected = NO;
	} else if (self.selectedValue == RadiusControlValueSecond) {
		self.firstSubview.selected = NO;
		self.secondSubview.selected = YES;
		self.thirdSubview.selected = NO;
		self.fourthSubview.selected = NO;
	} else if (self.selectedValue == RadiusControlValueThird) {
		self.firstSubview.selected = NO;
		self.secondSubview.selected = NO;
		self.thirdSubview.selected = YES;
		self.fourthSubview.selected = NO;
	} else if (self.selectedValue == RadiusControlValueFourth) {
		self.firstSubview.selected = NO;
		self.secondSubview.selected = NO;
		self.thirdSubview.selected = NO;
		self.fourthSubview.selected = YES;		
	}
	[UIView commitAnimations];
}

- (void)_showSubviewsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	self.animating = NO;
	self.expanded = YES;
	self.userInteractionEnabled = YES;
	
	UIButton *firstButton = [[UIButton alloc] initWithFrame:self.firstSubview.frame];
	firstButton.tag = kRadiusControlFirstSubviewButton;
	[firstButton addTarget:self action:@selector(_onFirstButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:firstButton];
	[firstButton release];
	
	UIButton *secondButton = [[UIButton alloc] initWithFrame:self.secondSubview.frame];
	secondButton.tag = kRadiusControlSecondSubviewButton;
	[secondButton addTarget:self action:@selector(_onSecondButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:secondButton];
	[secondButton release];
	
	UIButton *thirdButton = [[UIButton alloc] initWithFrame:self.thirdSubview.frame];
	thirdButton.tag = kRadiusControlThirdSubviewButton;
	[thirdButton addTarget:self action:@selector(_onThirdButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:thirdButton];
	[thirdButton release];
	
	UIButton *fourthButton = [[UIButton alloc] initWithFrame:self.fourthSubview.frame];
	fourthButton.tag = kRadiusControlFourthSubviewButton;
	[fourthButton addTarget:self action:@selector(_onFourthButton:) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:fourthButton];
	[fourthButton release];
	
	
	self.hideControlTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(_handleDecreasingAnimation) userInfo:nil repeats:NO];
}

#pragma mark -
#pragma mark Decreasing 

- (void)_handleDecreasingAnimation
{
	[self _destroyHideControlTimer];
	
	if (self.isAnimating) {
		return;
	}
	
	self.animating = YES;
	self.userInteractionEnabled = NO;
	
	NSUInteger buttons[4] = {
		kRadiusControlFirstSubviewButton, 
		kRadiusControlSecondSubviewButton, 
		kRadiusControlThirdSubviewButton, 
		kRadiusControlFourthSubviewButton
	};
	
	for (int i = 0; i < 4; i++) {
		NSUInteger tag = buttons[i];
		UIView *buttonView = [self viewWithTag:tag];
		if (buttonView) {
			[buttonView removeFromSuperview];
		}
	}
	
	// Animation
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(_hideSubviewsAnimationDidStop:finished:context:)];
	[UIView setAnimationDuration:0.1f];
	self.refreshButtonView.alpha = 0.0;	
	
	self.firstSubview.alpha = 0.0;
	self.secondSubview.alpha = 0.0;
	self.thirdSubview.alpha = 0.0;
	self.fourthSubview.alpha = 0.0;
	
	[UIView commitAnimations];
}

- (void)_hideSubviewsAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self _startViewSizeDecreasingAnimation];
}

- (void)_decreasingAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	self.animating = NO;
	self.expanded = NO;
	self.userInteractionEnabled = YES;
	
	
	RadiusControlSubview *selectedView = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:self.selectedValue];
	selectedView.frame = CGRectMake(56.0f, 0.0f, selectedView.frame.size.width, selectedView.frame.size.height);
	selectedView.alpha = 1.0;
	[self addSubview:selectedView];
	self.currentSelectedView = selectedView;
}

- (void)_startViewSizeDecreasingAnimation
{
	CGRect bounds = self.bounds;
	CGFloat height = bounds.size.height;
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelegate:self];
	//[UIView setAnimationDidStopSelector:@selector(decreasingAnimationDidStop:finished:context:)];
	[UIView setAnimationDidStopSelector:@selector(_decreasingAnimationDidStop:finished:context:)];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	self.bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, kRadiusControlNotExpandedWidth, height);
	self.center = CGPointMake(self.notExpandedCenterPoint.x, self.center.y);
	
	self.refreshButtonView.alpha = 0.0;
	
	[UIView commitAnimations];
}

#pragma mark -

- (void)_toogleSize
{
	// Center Punkt festhalten
	if (self.isExpanded == NO && CGPointEqualToPoint(self.notExpandedCenterPoint, CGPointMake(-1*CGFLOAT_MAX, -1*CGFLOAT_MAX))) {
		self.notExpandedCenterPoint = self.center;
	}
	
	if (self.isAnimating) {
		return;
	}
	
	// Animating
	if (NO == self.isExpanded) {
		// Vergroessern
		[self _handleExpandingAnimation];
	} else {
		// Verkleinern
		[self _handleDecreasingAnimation];
	}
}

- (void)_initControl
{
	_expanded = NO;
	_animating = NO;
	
	_selectedValue = RadiusControlValueFirst;
	
	_notExpandedCenterPoint = CGPointMake(-1*CGFLOAT_MAX, -1*CGFLOAT_MAX);
	
	//_label = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 6.0f, 37.0f, 19.0f)];
	_label = [[UILabel alloc] initWithFrame:CGRectMake(8.0f, 4.0f, 35.0f, 15.0f)];
	_label.text = @"Radius";
	[_label sizeToFit];
	_label.backgroundColor = [UIColor clearColor];
	_label.textColor = [UIColor colorWithHex:0x333333];
	_label.font = [UIFont boldSystemFontOfSize:12.0f];
	[self addSubview:_label];
	
	
	self.backgroundColor = [UIColor clearColor];
	
	
	self.layer.borderColor = [[UIColor colorWithWhite:1.0 alpha:0.4] CGColor];
	self.layer.borderWidth = 1.0f;
	self.layer.cornerRadius = 10.0f;

	RadiusControlSubview *selectedView = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:_selectedValue];
	selectedView.frame = CGRectMake(56.0f, 0.0f, selectedView.frame.size.width, selectedView.frame.size.height);
	selectedView.alpha = 1.0;
	[self addSubview:selectedView];
	self.currentSelectedView = selectedView;
	
	
	// First
	self.firstSubview = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:RadiusControlValueFirst];
	[self addSubview:self.firstSubview];
	
	// Second
	self.secondSubview = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:RadiusControlValueSecond];
	[self addSubview:self.secondSubview];
	
	// Third
	self.thirdSubview = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:RadiusControlValueThird];
	[self addSubview:self.thirdSubview];

	// Fourth
	self.fourthSubview = [RadiusControlSubviewWithLabel radiusControlSubviewWithLabelForValue:RadiusControlValueFourth];
	[self addSubview:self.fourthSubview];

	
	_refreshButtonView = [[RadiusControlSubview alloc] initWithFrame:CGRectMake(262.0, 0.0f, 30.0f, self.bounds.size.height)];
	_refreshButtonView.alpha = 0.0;
	[self addSubview:_refreshButtonView];
	

	UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[refreshButton setImage:[UIImage imageNamed:@"refresh.png"] forState:UIControlStateNormal];
	[refreshButton addTarget:self action:@selector(onRefreshAction:) forControlEvents:UIControlEventTouchUpInside];
	refreshButton.frame = CGRectMake(3.0f, 0.0f, 30.0f, 30.0f);
	[_refreshButtonView addSubview:refreshButton];
}

- (void)_destroyHideControlTimer
{
	[_hideControlTimer invalidate], [_hideControlTimer release], _hideControlTimer = nil;
}

#pragma mark -

- (void)dealloc {
	[_label release], _label = nil;
	[_refreshButtonView release], _refreshButtonView = nil;
	
	[_firstSubview release], _firstSubview = nil;
	[_secondSubview release], _secondSubview = nil;
	[_thirdSubview release], _thirdSubview = nil;
	[_fourthSubview release], _fourthSubview = nil;
	[_currentSelectedView release], _currentSelectedView = nil;
	
	[self _destroyHideControlTimer];
	
    [super dealloc];
}


@end

#pragma mark -

@implementation RadiusControlSubview

@synthesize selected = _selected;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
		_selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)isSelected
{
	if (isSelected) {
		self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.3];
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.4].CGColor);
	CGContextSetLineWidth(context, 3.0);
	
	CGFloat gap = 0.0f;
	
	CGContextMoveToPoint(context, 0.0f, 0.0f + gap);
	CGContextAddLineToPoint(context, 0.0f, self.bounds.size.height - gap);
	
	CGContextStrokePath(context);
}

#pragma mark -

- (void)dealloc {
    [super dealloc];
}


@end

#pragma mark -

@implementation RadiusControlSubviewWithLabel

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.font = [UIFont boldSystemFontOfSize:12.0f];
		_label.textAlignment = UITextAlignmentCenter;
		_label.textColor = [UIColor colorWithHex:0x333333];
		_label.backgroundColor = [UIColor clearColor];
		[self addSubview:_label];
    }
    return self;
}

- (void)layoutSubviews
{
	CGRect bounds = self.bounds;
	self.label.frame = CGRectMake(0.0f, 7.0, bounds.size.width, 15.0f);
}

+ (RadiusControlSubviewWithLabel *)radiusControlSubviewWithLabelForValue:(RadiusControlValue)aValue
{
	if (aValue == RadiusControlValueFirst) {
		RadiusControlSubviewWithLabel *subview = [[RadiusControlSubviewWithLabel alloc] initWithFrame:CGRectMake(56.0f, 0.0f, 51.0f, 30.0f)];		
		subview.label.text = @"1 km";
		subview.alpha = 0.0;
		
		return [subview autorelease];
	}

	// Second
	if (aValue == RadiusControlValueSecond) {
		RadiusControlSubviewWithLabel *secondSubview = [[RadiusControlSubviewWithLabel alloc] initWithFrame:CGRectMake(107.0f, 0.0f, 51.0f, 30.0f)];
		secondSubview.alpha = 0.0;
		secondSubview.label.text = @"100 km";

		return [secondSubview autorelease];
	}
	
	// Third
	if (aValue == RadiusControlValueThird) {
		RadiusControlSubviewWithLabel *thirdSubview = [[RadiusControlSubviewWithLabel alloc] initWithFrame:CGRectMake(158.0f, 0.0f, 54.0f, 30.0f)];
		thirdSubview.alpha = 0.0;
		thirdSubview.label.text = @"1000 km";
		
		return [thirdSubview autorelease];
	}
	
	// Fourth
	if (aValue == RadiusControlValueFourth) {
		RadiusControlSubview *fourthSubview = [[RadiusControlSubview alloc] initWithFrame:CGRectMake(212.0f, 0.0f, 51.0f, 30.0f)];
		fourthSubview.alpha = 0.0;
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"endless.png"]];
		imageView.frame = CGRectMake(1.0f, 2.0f, 26.0f, 26.0f);
		[fourthSubview addSubview:imageView];
		[imageView release];
		UILabel *kmLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		kmLabel.font = [UIFont boldSystemFontOfSize:12];
		kmLabel.backgroundColor = [UIColor clearColor];
		kmLabel.textColor = [UIColor colorWithHex:0x333333];
		kmLabel.text = @"km";
		[kmLabel sizeToFit];
		kmLabel.frame = CGRectMake(26.0f, 7.0f, kmLabel.frame.size.width, kmLabel.frame.size.height);
		[fourthSubview addSubview:kmLabel];
		[kmLabel release];
		
		return [fourthSubview autorelease];
	}	
	
	return nil;
}

#pragma mark -

- (void) dealloc
{
	[_label release], _label = nil;
	
	[super dealloc];
}


@end

