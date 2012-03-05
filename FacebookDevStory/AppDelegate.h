//
//  AppDelegate.h
//  FacebookDevStory
//
//  Created by Tomi Joki-Korpela on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

#include <stdint.h>

@class ViewController;


@interface AppDelegate : UIResponder <UIApplicationDelegate, FBSessionDelegate, FBDialogDelegate, FBRequestDelegate> {

    Facebook *facebook;
    id whoamiRequest;
    int64_t fbid;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) Facebook *facebook;

@property (strong, nonatomic) ViewController *viewController;


-(int)itemType;

-(void)setItems:(int)itemType value:(int)value;
-(int)numItems:(int)itemType;


@end
