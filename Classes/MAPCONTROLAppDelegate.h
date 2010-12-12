//
//  MAPCONTROLAppDelegate.h
//  MAPCONTROL
//
//  Created by Andreas Kompanez on 24.07.10.
//  Copyright Endless Numbered 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAPCONTROLViewController;

@interface MAPCONTROLAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MAPCONTROLViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MAPCONTROLViewController *viewController;

@end

