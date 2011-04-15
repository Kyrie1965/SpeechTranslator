//
//  Speech_TranslatorAppDelegate.m
//  Speech Translator
//
//  Created by Yuri Yuriev on 14.04.11.
//  Copyright 2011 Yuri Yuriev. All rights reserved.
//

#import "Speech_TranslatorAppDelegate.h"
#import "GoogleASR.h"

@implementation Speech_TranslatorAppDelegate

@synthesize window;


- (void)awakeFromNib
{
    [textLabel setHidden:YES];
    [indicator setUsesThreadedAnimation:YES];
    [indicator setDisplayedWhenStopped:NO];
    
    [button setTitle:NSLocalizedString(@"Record", @"")];
    [window setTitle:NSLocalizedString(@"Title", @"")];
    
    [popUp removeAllItems];
	[popUp addItemWithTitle:NSLocalizedString(@"RUEN", @"")];
	[popUp addItemWithTitle:NSLocalizedString(@"ENRU", @"")];
    
    [window center];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    googleASR = [[GoogleASR alloc] init];
    googleASR.delegate = self;
    googleTranslate = [[GoogleTranslate alloc] init];
    googleTranslate.delegate = self;
    microsoftTTS = [[MicrosoftTTS alloc] init];
    microsoftTTS.delegate = self;
    
    recording = NO;
    recordPath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"SpeechTranslator"] retain];
    
    BOOL success = NO;
    
    mCaptureSession = [[QTCaptureSession alloc] init];
    
    QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
    
    if (!audioDevice)
    {
        [mCaptureSession release], mCaptureSession = nil;
        
        [textLabel setStringValue:NSLocalizedString(@"AudioError", @"")];
        [button setHidden:YES];
        [popUp setHidden:YES];
        [textLabel setHidden:NO];
    }
    
    success = [audioDevice open:NULL];
    
    if (!success)
    {
        [mCaptureSession release], mCaptureSession = nil;
        
        [textLabel setStringValue:NSLocalizedString(@"AudioError", @"")];
        [button setHidden:YES];
        [popUp setHidden:YES];
        [textLabel setHidden:NO];
    }
    
    mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
    success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:NULL];
    
    if (!success)
    {
        [mCaptureSession release], mCaptureSession = nil;
        [mCaptureAudioDeviceInput release], mCaptureAudioDeviceInput = nil;
        
        [textLabel setStringValue:NSLocalizedString(@"AudioError", @"")];
        [button setHidden:YES];
        [popUp setHidden:YES];
        [textLabel setHidden:NO];
    }
    
    mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
    success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:NULL];
    
    if (!success)
    {
        [mCaptureSession release], mCaptureSession = nil;
        [mCaptureAudioDeviceInput release], mCaptureAudioDeviceInput = nil;
        [mCaptureMovieFileOutput release], mCaptureMovieFileOutput = nil;
        
        //error handler
    }
    
    [mCaptureMovieFileOutput setDelegate:self];
    
    [mCaptureMovieFileOutput setCompressionOptions:[QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"] forConnection:[[mCaptureMovieFileOutput connections] objectAtIndex:0]];
    
    [mCaptureSession startRunning];        
}


- (void)dealloc
{
    if (recordTimer)
    {
        [recordTimer invalidate];
        [recordTimer release];
        recordTimer = nil;
    }
    
    if (mCaptureSession) [mCaptureSession release], mCaptureSession = nil;
    if (mCaptureAudioDeviceInput)[mCaptureAudioDeviceInput release], mCaptureAudioDeviceInput = nil;
    if (mCaptureMovieFileOutput) [mCaptureMovieFileOutput release], mCaptureMovieFileOutput = nil;
    if (recordPath) [recordPath release];
    
    [super dealloc];
}


- (IBAction)popUpAction:(id)sender
{
    
}


- (IBAction)buttonAction:(id)sender
{
    if (recording)
    {
        [recordTimer invalidate];
        [recordTimer release];
        recordTimer = nil;
        
        recording = NO;        
        [button setTitle:NSLocalizedString(@"Record", @"")];
        [popUp setHidden:NO];
        [textLabel setHidden:YES];
                
        [mCaptureMovieFileOutput recordToOutputFileURL:nil];
    }
    else
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:recordPath error:NULL];
        [fileManager createDirectoryAtPath:recordPath withIntermediateDirectories:YES attributes:nil error:NULL];
        
        [mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:[recordPath stringByAppendingPathComponent:@"record.m4a"]]];

        recording = YES;
        [button setTitle:NSLocalizedString(@"Stop", @"")];
        [textLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"RecordMessage", @""), recordMAXSec]];        
        [popUp setHidden:YES];
        [textLabel setHidden:NO];
        
        timerInitDate = [[NSDate date] timeIntervalSince1970];
        
        recordTimer = [[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(recordTimerAction:) userInfo:nil repeats:YES] retain];
    }
}


- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
    NSTask *aTask = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    
    [args addObject:@"-i"];
    [args addObject:@"record.m4a"];
    [args addObject:@"-acodec"];
    [args addObject:@"flac"];
    [args addObject:@"-ac"];
    [args addObject:@"1"];
    [args addObject:@"-ar"];
    [args addObject:@"16000"];
    [args addObject:@"record.flac"];
    [aTask setCurrentDirectoryPath:recordPath];
    [aTask setLaunchPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ffmpeg"]];
    [aTask setArguments:args];
    [aTask launch];
    [aTask waitUntilExit];
    [aTask release];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[recordPath stringByAppendingPathComponent:@"record.flac"]])
    {
        [popUp setHidden:YES];
        [button setHidden:YES];
        [textLabel setStringValue:NSLocalizedString(@"DataHandling", @"")];
        [textLabel setHidden:NO];
        [indicator startAnimation:self];
        
        NSString *language;
        
        if ([popUp indexOfSelectedItem] == 0)
            language = @"ru-RU";
        else
            language = @"en-US";
        
        [googleASR speechRecognition:[recordPath stringByAppendingPathComponent:@"record.flac"] language:language];
    }
    else
    {
        NSRunCriticalAlertPanel(NSLocalizedString(@"Error", @""), NSLocalizedString(@"RecordError", @""), NSLocalizedString(@"Continue", @"") ,nil, nil);
    }
}


- (void)recordTimerAction:(NSTimer *)timer
{
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    
    int t = currentTime - timerInitDate;
    
    if (t < recordMAXSec)
    {
        [textLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"RecordMessage", @""), recordMAXSec - t]];        
    }
    else
    {
        [recordTimer invalidate];
        [recordTimer release];
        recordTimer = nil;

        recording = NO;        
        [button setTitle:NSLocalizedString(@"Record", @"")];
        [popUp setHidden:NO];
        [textLabel setHidden:YES];
        
        [mCaptureMovieFileOutput recordToOutputFileURL:nil];        
    }
}


- (void)didSR:(NSString *)text
{
    NSString *inLanguage;
    NSString *outLanguage;
    
    if ([popUp indexOfSelectedItem] == 0)
    {
        inLanguage = @"ru";
        outLanguage = @"en";
    }
    else
    {
        inLanguage = @"en";
        outLanguage = @"ru";
    }
    
    [googleTranslate translate:text from:inLanguage to:outLanguage];
}


- (void)didTranslate:(NSString *)translatedText
{
    NSString *language;
    
    if ([popUp indexOfSelectedItem] == 0)
        language = @"en";
    else
        language = @"ru";
    
    [microsoftTTS textToSpeech:translatedText language:language];
}


- (void)dataReady:(NSData *)audioData
{
    [popUp setHidden:NO];
    [button setHidden:NO];
    [textLabel setHidden:YES];
    [indicator stopAnimation:self];
    
	if (player)
	{
		[player stop];
		[player release];
		player = nil;
	}
	
	player = [[NSSound alloc] initWithData:audioData];
	[player play];    
}


- (void)didFail
{
    [popUp setHidden:NO];
    [button setHidden:NO];
    [textLabel setHidden:YES];
    [indicator stopAnimation:self];    

    NSRunCriticalAlertPanel(NSLocalizedString(@"Error", @""), NSLocalizedString(@"DataError", @""), NSLocalizedString(@"Continue", @"") ,nil, nil);    
}


- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self];
    return YES;
}


@end
