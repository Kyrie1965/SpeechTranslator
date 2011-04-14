//
//  Speech_TranslatorAppDelegate.h
//  Speech Translator
//
//  Created by Yuri Yuriev on 14.04.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Speech_TranslatorAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
