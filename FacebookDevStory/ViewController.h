//
//  ViewController.h
//  FacebookDevStory
//
//  Created by Tomi Joki-Korpela on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

@class AppDelegate;

@interface ViewController : GLKViewController
{
    AppDelegate* appDelegate;
}
@property (assign) AppDelegate* appDelegate;
@end
