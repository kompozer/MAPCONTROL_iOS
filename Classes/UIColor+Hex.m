//
//  UIColor+Hex.m
//  DP1
//
//  Created by Andreas Kompanez on 25.05.10.
//  Copyright 2010 Endless Numbered. All rights reserved.
//

#import "UIColor+Hex.h"


@implementation UIColor (Hex)

+ (UIColor *)colorWithHex:(uint)rgbValue
{
	return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 
						   green:((float)((rgbValue & 0xFF00) >> 8))/255.0 
							blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end