//
//  RadiusControl.h
//  MAPCONTROL
//
//  Created by Andreas Kompanez on 24.07.10.
//  Copyright 2010 Endless Numbered. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RadiusControlSubview;
@class RadiusControlSubviewWithLabel;
@protocol RadiusControlDelegate;

typedef enum _RadiusControlValue {
	RadiusControlValueFirst = 1,
	RadiusControlValueSecond = 2,
	RadiusControlValueThird = 3,
	RadiusControlValueFourth = 4
} RadiusControlValue;


@interface RadiusControl : UIView {
	id <RadiusControlDelegate> _delegate; 
	BOOL _expanded;
	BOOL _animating;
	BOOL _delegateNotificationNeeded;
	
	UILabel *_label;
	CGPoint _notExpandedCenterPoint;
	
	RadiusControlSubview *_refreshButtonView;
	
	RadiusControlSubviewWithLabel *_firstSubview;
	RadiusControlSubviewWithLabel *_secondSubview;
	RadiusControlSubviewWithLabel *_thirdSubview;
	RadiusControlSubview *_fourthSubview;
	
	RadiusControlSubview *_currentSelectedView;
	
	RadiusControlValue _selectedValue;
	
	NSTimer *_hideControlTimer;
}

@property (nonatomic, assign, readonly, getter=isExpanded) BOOL expanded;
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, assign) id <RadiusControlDelegate> delegate;
@property (nonatomic, retain) RadiusControlSubview *refreshButtonView;

- (void)onRefreshAction:(id)sender;

@end

@protocol RadiusControlDelegate <NSObject>

@optional

- (void)radiusControl:(RadiusControl *)theControl valueChangedTo:(NSNumber *)theNewValue;

- (void)radiusControlRefreshRequired:(RadiusControl *)theControl;

@end


@interface RadiusControlSubview : UIView {
	BOOL _selected;
}

@property (nonatomic, assign, getter=isSelected) BOOL selected;

@end

@interface RadiusControlSubviewWithLabel : RadiusControlSubview
{
	UILabel *_label;
}

@property (nonatomic, retain) UILabel *label;

+ (RadiusControlSubviewWithLabel *)radiusControlSubviewWithLabelForValue:(RadiusControlValue)aValue;

@end