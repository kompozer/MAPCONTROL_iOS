//
//  MAPCONTROLViewController.h
//  MAPCONTROL
//
//  Created by Andreas Kompanez on 24.07.10.
//  Copyright Endless Numbered 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RadiusControl.h"

@interface MAPCONTROLViewController : UIViewController {
	RadiusControl *_radiusControl;
}

@property (nonatomic, retain) IBOutlet RadiusControl *radiusControl;

- (IBAction)onHideControl:(id)sender;

@end

