//
//  AppDelegate.m
//  FacebookDevStory
//
//  Created by Tomi Joki-Korpela on 3/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"


@implementation AppDelegate

@synthesize window = _window;
@synthesize facebook;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    fbid=-1;
    facebook = [[Facebook alloc] initWithAppId:@"359344330763412" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        [self whoami];
    }
    
    if (![facebook isSessionValid]) {
        [facebook authorize:nil];
    }

    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil] autorelease];
    } else {
        self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil] autorelease];
    }
    self.viewController.appDelegate = self;
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];

    // Add the requests dialog button
    UIButton *requestDialogButton = [UIButton 
                                     buttonWithType:UIButtonTypeRoundedRect];
    requestDialogButton.frame = CGRectMake(40, 150, 200, 40);
    [requestDialogButton setTitle:@"Send Request" forState:UIControlStateNormal];
    [requestDialogButton addTarget:self 
                            action:@selector(requestDialogButtonClicked)
                  forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:requestDialogButton];

    // Add the feed dialog button
    UIButton *feedDialogButton = [UIButton 
                                  buttonWithType:UIButtonTypeRoundedRect];
    feedDialogButton.frame = CGRectMake(40, 260, 200, 40);
    [feedDialogButton setTitle:@"Publish Feed" forState:UIControlStateNormal];
    [feedDialogButton addTarget:self 
                         action:@selector(feedDialogButtonClicked) 
               forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:feedDialogButton];

    // Add the logout button
    /*
    UIButton *logoutButton = [UIButton 
                                  buttonWithType:UIButtonTypeRoundedRect];
    feedDialogButton.frame = CGRectMake(40, 370, 200, 40);
    [feedDialogButton setTitle:@"Logout" forState:UIControlStateNormal];
    [feedDialogButton addTarget:self 
                         action:@selector(logoutButtonClicked) 
               forControlEvents:UIControlEventTouchUpInside];
    [self.viewController.view addSubview:logoutButton];
     */

    [facebook requestWithGraphPath:@"me/apprequests" andDelegate:self];
    
    // Override point for customization after application launch.
    return YES;
}

// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url];
}

- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    [self whoami];
}

-(void)whoami
{
    whoamiRequest = [self.facebook requestWithGraphPath:@"/me" andDelegate:self];
}


- (void)fbDidNotLogin:(BOOL)cancelled {
}

- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt {
    NSLog(@"token extended");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:accessToken forKey:@"FBAccessTokenKey"];
    [defaults setObject:expiresAt forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

- (void)fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    [facebook logout];
}
							
- (void)fbSessionInvalidated {
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [facebook extendAccessTokenIfNeeded];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}


// Method that gets called when the request dialog button is pressed
- (void) requestDialogButtonClicked {
    // The action links to be shown with the post in the feed

    NSMutableDictionary* params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"sent you a FB application feature",  @"message",
     @"Check this out", @"notification_text",
     @"http://www.facebookmobileweb.com/hackbook/img/facebook_icon_large.png", @"picture",
     nil];  
    [facebook dialog:@"apprequests"
           andParams:params
         andDelegate:self];
}

// FBDialogDelegate
- (void)dialogDidComplete:(FBDialog *)dialog {
    NSLog(@"dialog completed successfully");
}

// Method that gets called when the feed dialog button is pressed
- (void) feedDialogButtonClicked {
    NSMutableDictionary *params = 
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"Testing Feed Dialog", @"name",
     @"Feed Dialogs are Awesome.", @"caption",
     @"Check out how to use Facebook Dialogs.", @"description",
     @"http://www.example.com/", @"link",
     @"http://fbrell.com/f8.jpg", @"picture",
     nil];  
    [facebook dialog:@"feed"
           andParams:params
         andDelegate:self];
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    NSLog(@"received response");

    if(request == whoamiRequest)
    {
        
        NSString* uid = [result objectForKey:@"id"];
        fbid = [uid longLongValue];
        return;
    }
    
    if (result != nil) {
        NSArray *resultData = [result objectForKey:@"data"];
        if ([resultData count] > 0) {
            for (NSDictionary *requestObject in resultData) {
                NSString *requestID = [requestObject objectForKey:@"id"];
                NSString *senderID = [[requestObject objectForKey:@"from"] objectForKey:@"id"];
                NSString *recipientID = [[requestObject objectForKey:@"to"] objectForKey:@"id"]; 
                NSLog(@"request id:%@ sender:%@ recipient:%@", requestID, senderID, recipientID);
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [facebook requestWithGraphPath:requestID andParams:params andHttpMethod:@"DELETE" andDelegate:self];
            }
        }
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Error message: %@", [[error userInfo] objectForKey:@"error_msg"]);
}


// Method that gets called when the request dialog button is pressed
- (void) logoutButtonClicked {
    [facebook logout];
}

-(int)itemType
{
    return fbid%3;
}

-(void)setItems:(int)itemType value:(int)value
{
    NSString* item = nil;
    switch(itemType)
    {
        case 0: item = @"red"; break;
        case 1: item = @"green"; break;
        case 2: item = @"blue"; break;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[NSNumber numberWithInteger:value] forKey:item];

    [defaults synchronize];
    
}

-(int)numItems:(int)itemType
{
    NSString* item = nil;
    switch(itemType)
    {
        case 0: item = @"red"; break;
        case 1: item = @"green"; break;
        case 2: item = @"blue"; break;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber* num = [defaults objectForKey:item];
    return [num intValue];
}




@end
