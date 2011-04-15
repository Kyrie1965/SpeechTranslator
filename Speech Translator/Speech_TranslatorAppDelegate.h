//
//  Speech_TranslatorAppDelegate.h
//  Speech Translator
//
//  Created by Yuri Yuriev on 14.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>
#import <BGHUDAppKit/BGHUDAppKit.h>
#import "GoogleASR.h"
#import "GoogleTranslate.h"
#import "MicrosoftTTS.h"

#define recordMAXSec 5

@interface Speech_TranslatorAppDelegate : NSObject <NSApplicationDelegate>
{
    IBOutlet NSWindow *window;    
    IBOutlet NSButton *button;
    IBOutlet NSPopUpButton *popUp;    
    IBOutlet BGHUDLabel *textLabel;    
    IBOutlet NSProgressIndicator *indicator;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;
    QTCaptureDeviceInput        *mCaptureAudioDeviceInput;
    
    NSString *recordPath;
    BOOL recording;
    
    NSTimer *recordTimer;
    NSTimeInterval timerInitDate;
    
    GoogleASR *googleASR; 
    GoogleTranslate *googleTranslate; 
    MicrosoftTTS *microsoftTTS;
    
	NSSound *player;    
}


@property (assign) IBOutlet NSWindow *window;


- (IBAction)buttonAction:(id)sender;
- (IBAction)popUpAction:(id)sender;


@end
