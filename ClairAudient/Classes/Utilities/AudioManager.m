//
//  AudioManager.m
//  Audio_HelloWorld
//
//  Created by vedon on 7/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//
#define kInputBus 1
#define kOutputBus 0
#import "AudioManager.h"
#import "lame.h"
#import <AVFoundation/AVFoundation.h>
static AudioManager * audioManager = nil;

@interface AudioManager()

@property (nonatomic, assign, readwrite) AudioUnit          inputUnit;
@property (nonatomic, assign, readwrite) AudioUnit          outputUnit;
@property (nonatomic, assign, readwrite) AudioBufferList    *inputBuffer;
@property (nonatomic, assign, readwrite) BOOL               inputAvailable;
@property (nonatomic, assign, readwrite) UInt32             numInputChannels;
@property (nonatomic, assign, readwrite) UInt32             numOutputChannels;
@property (nonatomic, assign, readwrite) Float64            samplingRate;
@property (nonatomic, assign, readwrite) BOOL               isInterleaved;
@property (nonatomic, assign, readwrite) UInt32             numBytesPerSample;
@property (nonatomic, assign, readwrite) BOOL               playing;
@property (nonatomic, assign, readwrite) float              *inData;
@property (nonatomic, assign, readwrite) float              *outData;
@property (nonatomic, assign, readwrite) AudioStreamBasicDescription inputFormat;
@property (nonatomic, assign, readwrite) AudioStreamBasicDescription outputFormat;
//播放前必须设置函数
-(void)setupAudioSession;
-(void)setupAudioUnits;
-(NSString *)applicationDocumentsDirectory;
-(void)freeBuffers;
@end


@implementation AudioManager

+(AudioManager *)shareAudioManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        audioManager = [[AudioManager alloc]init];
        
    });
    return audioManager;
}

- (id)init
{
	if (self = [super init])
	{
        
        // Initialize a float buffer to hold audio
		self.inData  = (float *)calloc(8192, sizeof(float)); // probably more than we'll need
        self.outData = (float *)calloc(8192, sizeof(float));
        self.inputBlock = nil;
        self.outputBlock = nil;
        self.playing = NO;
        // self.playThroughEnabled = NO;
		
		// Fire up the audio session ( with steady error checking ... )
        [self setupAudioSession];
        
        // start audio units
        [self setupAudioUnits];
		
		return self;
		
	}
	
	return nil;
}

- (void)dealloc
{
    [super dealloc];
    free(self.inData);
    free(self.outData);
    [self freeBuffers];
}

- (void)freeBuffers
{
    if (self.inputBuffer){
        
		for(UInt32 i =0; i< self.inputBuffer->mNumberBuffers ; i++) {
            
			if(self.inputBuffer->mBuffers[i].mData){
                free(self.inputBuffer->mBuffers[i].mData);
            }
		}
        
        free(self.inputBuffer);
        self.inputBuffer = NULL;
    }
}

- (void)setForceOutputToSpeaker:(BOOL)forceOutputToSpeaker
{
    
#if !TARGET_IPHONE_SIMULATOR
    UInt32 value = forceOutputToSpeaker ? 1 : 0;
    // should not be fatal error
    OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(UInt32), &value);
    if (err != noErr){
        NSLog(@"Could not override audio output route to speaker");
    }
    else{
        _forceOutputToSpeaker = forceOutputToSpeaker;
    }
#else
    _forceOutputToSpeaker = forceOutputToSpeaker;
#endif
}

#pragma mark - Audio Methods


- (void)setupAudioSession
{
    // Set the audio session active
    NSError *err = nil;
    if (![[AVAudioSession sharedInstance] setActive:YES error:&err]){
        NSLog(@"Couldn't activate audio session: %@", err);
    }
    [self checkAudioSource];
}

- (void)setupAudioUnits
{
    UInt32 sessionCategory = kAudioSessionCategory_PlayAndRecord;
    CheckError(AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                                         sizeof (sessionCategory),
                                         &sessionCategory), "Couldn't set audio category");
    
    
    // Add a property listener, to listen to changes to the session
    CheckError(AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, sessionPropertyListener, (__bridge void*)self), "Couldn't add audio session property listener");
    
    // Set the buffer size, this will affect the number of samples that get rendered every time the audio callback is fired
    // A small number will get you lower latency audio, but will make your processor work harder
#if !TARGET_IPHONE_SIMULATOR
    Float32 preferredBufferSize = 0.0232;
    CheckError( AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(preferredBufferSize), &preferredBufferSize), "Couldn't set the preferred buffer duration");
#endif
    
    
    [self checkSessionProperties];

    AudioComponentDescription inputDescription = {0};
    inputDescription.componentType = kAudioUnitType_Output;
    inputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    inputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;

    // Get component
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &inputDescription);
    CheckError( AudioComponentInstanceNew(inputComponent, &_inputUnit), "Couldn't create the output audio unit");
    

    
    // Enable input
    UInt32 one = 1;
    CheckError( AudioUnitSetProperty(_inputUnit,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input,
                                     kInputBus,
                                     &one,
                                     sizeof(one)), "Couldn't enable IO on the input scope of output unit");
    
    //获取kAudioUnitScope_Input：硬件输入，输出的AudioStreamBasicDescription
    UInt32 size;
	size = sizeof( AudioStreamBasicDescription );
	CheckError( AudioUnitGetProperty(_inputUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input,
                                     1,
                                     &_inputFormat,
                                     &size ),
               "Couldn't get the hardware input stream format");
	
	size = sizeof( AudioStreamBasicDescription );
	CheckError( AudioUnitGetProperty(_inputUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Output,
                                     1,
                                     &_outputFormat,
                                     &size ),
               "Couldn't get the hardware output stream format");
    
    _inputFormat.mSampleRate = 44100.0;
    _outputFormat.mSampleRate = 44100.0;
    self.samplingRate = _inputFormat.mSampleRate;
    self.numBytesPerSample = _inputFormat.mBitsPerChannel / 8;
    
    size = sizeof(AudioStreamBasicDescription);
	CheckError(AudioUnitSetProperty(_inputUnit,
									kAudioUnitProperty_StreamFormat,
									kAudioUnitScope_Output,
									kInputBus,
									&_outputFormat,
									size),
			   "Couldn't set the ASBD on the audio unit (after setting its sampling rate)");
    UInt32 numFramesPerBuffer;
    size = sizeof(UInt32);
    CheckError(AudioUnitGetProperty(_inputUnit,
                                    kAudioUnitProperty_MaximumFramesPerSlice,
                                    kAudioUnitScope_Global,
                                    kOutputBus,
                                    &numFramesPerBuffer,
                                    &size),
               "Couldn't get the number of frames per callback");
    
    UInt32 bufferSizeBytes = _outputFormat.mBytesPerFrame * _outputFormat.mFramesPerPacket * numFramesPerBuffer;
	if (_outputFormat.mFormatFlags & kAudioFormatFlagIsNonInterleaved) {
        // The audio is non-interleaved
        printf("Not interleaved!\n");
        self.isInterleaved = NO;
		UInt32 propsize = offsetof(AudioBufferList, mBuffers[0]) + (sizeof(AudioBuffer) * _outputFormat.mChannelsPerFrame);
		
		//malloc buffer lists
		self.inputBuffer = (AudioBufferList *)malloc(propsize);
		self.inputBuffer->mNumberBuffers = _outputFormat.mChannelsPerFrame;
		
		for(UInt32 i =0; i< self.inputBuffer->mNumberBuffers ; i++) {
			self.inputBuffer->mBuffers[i].mNumberChannels = 1;
			self.inputBuffer->mBuffers[i].mDataByteSize = bufferSizeBytes;
			self.inputBuffer->mBuffers[i].mData = malloc(bufferSizeBytes);
            memset(self.inputBuffer->mBuffers[i].mData, 0, bufferSizeBytes);
		}
        
	} else {
		printf ("Format is interleaved\n");
        self.isInterleaved = YES;
        
		// allocate an AudioBufferList plus enough space for array of AudioBuffers
		UInt32 propsize = offsetof(AudioBufferList, mBuffers[0]) + (sizeof(AudioBuffer) * 1);
		
		//malloc buffer lists
		self.inputBuffer = (AudioBufferList *)malloc(propsize);
		self.inputBuffer->mNumberBuffers = 1;
		
		//pre-malloc buffers for AudioBufferLists
		self.inputBuffer->mBuffers[0].mNumberChannels = _outputFormat.mChannelsPerFrame;
		self.inputBuffer->mBuffers[0].mDataByteSize = bufferSizeBytes;
		self.inputBuffer->mBuffers[0].mData = malloc(bufferSizeBytes);
        memset(self.inputBuffer->mBuffers[0].mData, 0, bufferSizeBytes);
        
	}
    
    
    // Slap a render callback on the unit
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = inputCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    
    CheckError( AudioUnitSetProperty(_inputUnit,
                                     kAudioOutputUnitProperty_SetInputCallback,
                                     kAudioUnitScope_Global,
                                     1,
                                     &callbackStruct,
                                     sizeof(callbackStruct)), "Couldn't set the callback on the input unit");
    
    
    callbackStruct.inputProc = renderCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    CheckError( AudioUnitSetProperty(_inputUnit,
                                     kAudioUnitProperty_SetRenderCallback,
                                     kAudioUnitScope_Input,
                                     0,
                                     &callbackStruct,
                                     sizeof(callbackStruct)),
               "Couldn't set the render callback on the input unit");
	CheckError(AudioUnitInitialize(_inputUnit), "Couldn't initialize the output unit");

    
}
- (void)pause {
	
	if (self.playing) {
        CheckError( AudioOutputUnitStop(_inputUnit), "Couldn't stop the output unit");
		self.playing = NO;
	}
    
}

- (void)play {
	
	UInt32 isInputAvailable=0;
    UInt32 size = sizeof(isInputAvailable);
	CheckError(AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable,
                                        &size,
                                        &isInputAvailable), "Couldn't check if input was available");
    self.inputAvailable = isInputAvailable;
    
	if ( self.inputAvailable ) {
		// Set the audio session category for simultaneous play and record
		if (!self.playing) {
			CheckError( AudioOutputUnitStart(_inputUnit), "Couldn't start the output unit");
            self.playing = YES;
            
		}
	}
    
}

//转换
- (void)audio_PCMtoMP3WithSourceFile:(NSString *)sourceFile destinationFile:(NSString *)desFile withSampleRate:(NSInteger)sampleRate
{
    NSString *cafFilePath = sourceFile;
    
    NSString *mp3FilePath = desFile;
    
    NSFileManager* fileManager=[NSFileManager defaultManager];
    if([fileManager removeItemAtPath:mp3FilePath error:nil])
    {
        NSLog(@"删除");
    }
    
    @try {
        int read, write;
        
        FILE *pcm = fopen([cafFilePath cStringUsingEncoding:NSUTF8StringEncoding], "rb");  //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3FilePath cStringUsingEncoding:NSUTF8StringEncoding], "wb");  //output 输出生成的Mp3文件位置
        
        const int PCM_SIZE = 8192*2;
        const int MP3_SIZE = 8192*2;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, sampleRate);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);
        
        do {
            read = fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
    }
    @finally {

    }
}

#pragma mark - Render Methods
OSStatus inputCallback   (void						*inRefCon,
                          AudioUnitRenderActionFlags	* ioActionFlags,
                          const AudioTimeStamp 		* inTimeStamp,
                          UInt32						inOutputBusNumber,
                          UInt32						inNumberFrames,
                          AudioBufferList			* ioData)
{
    @autoreleasepool {
        
        AudioManager *sm = (__bridge AudioManager *)inRefCon;
        
        if (!sm.playing)
            return noErr;
        if (sm.inputBlock == nil)
            return noErr;
        
        
        // Check the current number of channels
        // Let's actually grab the audio
#if TARGET_IPHONE_SIMULATOR
        // this is a workaround for an issue with core audio on the simulator, //
        //  likely due to 44100 vs 48000 difference in OSX //
        if( inNumberFrames == 471 )
            inNumberFrames = 470;
#endif
        CheckError( AudioUnitRender(sm.inputUnit, ioActionFlags, inTimeStamp, inOutputBusNumber, inNumberFrames, sm.inputBuffer), "Couldn't render the output unit");
        
        
        // Convert the audio in something manageable
        // For Float32s ...
        if ( sm.numBytesPerSample == 4 ) // then we've already got flaots
        {
            
            float zero = 0.0f;
            if ( ! sm.isInterleaved ) { // if the data is in separate buffers, make it interleaved
                for (int i=0; i < sm.numInputChannels; ++i) {
                    vDSP_vsadd((float *)sm.inputBuffer->mBuffers[i].mData, 1, &zero, sm.inData+i,
                               sm.numInputChannels, inNumberFrames);
                }
            }
            else { // if the data is already interleaved, copy it all in one happy block.
                // TODO: check mDataByteSize is proper
                memcpy(sm.inData, (float *)sm.inputBuffer->mBuffers[0].mData, sm.inputBuffer->mBuffers[0].mDataByteSize);
            }
        }
        
        // For SInt16s ...
        else if ( sm.numBytesPerSample == 2 ) // then we're dealing with SInt16's
        {
            if ( ! sm.isInterleaved ) {
                for (int i=0; i < sm.numInputChannels; ++i) {
                    vDSP_vflt16((SInt16 *)sm.inputBuffer->mBuffers[i].mData, 1, sm.inData+i, sm.numInputChannels, inNumberFrames);
                }
            }
            else {
                vDSP_vflt16((SInt16 *)sm.inputBuffer->mBuffers[0].mData, 1, sm.inData, 1, inNumberFrames*sm.numInputChannels);
            }
            
            float scale = 1.0 / (float)INT16_MAX;
            vDSP_vsmul(sm.inData, 1, &scale, sm.inData, 1, inNumberFrames*sm.numInputChannels);
        }
        
        sm.inputBlock(sm.inData, inNumberFrames, sm.numInputChannels);
        
    }
    
    return noErr;
	
	
}



OSStatus renderCallback (void						*inRefCon,
                         AudioUnitRenderActionFlags	* ioActionFlags,
                         const AudioTimeStamp 		* inTimeStamp,
                         UInt32						inOutputBusNumber,
                         UInt32						inNumberFrames,
                         AudioBufferList				* ioData)
{
    // autorelease pool for much faster ARC performance on repeated calls from separate thread
    @autoreleasepool {
        
        AudioManager *sm = (__bridge AudioManager *)inRefCon;
        float zero = 0.0;
        
        
        for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
            memset(ioData->mBuffers[iBuffer].mData, 0, ioData->mBuffers[iBuffer].mDataByteSize);
        }
        
        if (!sm.playing)
            return noErr;
        if (!sm.outputBlock)
            return noErr;
        
        
        // Collect data to render from the callbacks
        sm.outputBlock(sm.outData, inNumberFrames, sm.numOutputChannels);
        
        
        // Put the rendered data into the output buffer
        // TODO: convert SInt16 ranges to float ranges.
        if ( sm.numBytesPerSample == 4 ) // then we've already got floats
        {
            
            for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
                
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                
                for (int iChannel = 0; iChannel < thisNumChannels; ++iChannel) {
                    
                    int interleaveOffset = iChannel;
                    if (iBuffer < sm.numOutputChannels){
                        interleaveOffset += iBuffer;
                    }
                    
                    vDSP_vsadd(sm.outData+interleaveOffset, sm.numOutputChannels, &zero, (float *)ioData->mBuffers[iBuffer].mData, thisNumChannels, inNumberFrames);
                    
                }
            }
        }
        else if ( sm.numBytesPerSample == 2 ) // then we need to convert SInt16 -> Float (and also scale)
        {
            float scale = (float)INT16_MAX;
            vDSP_vsmul(sm.outData, 1, &scale, sm.outData, 1, inNumberFrames*sm.numOutputChannels);
            
            for (int iBuffer=0; iBuffer < ioData->mNumberBuffers; ++iBuffer) {
                
                int thisNumChannels = ioData->mBuffers[iBuffer].mNumberChannels;
                
                for (int iChannel = 0; iChannel < thisNumChannels; ++iChannel) {
                    
                    int interleaveOffset = iChannel;
                    if (iBuffer < sm.numOutputChannels){
                        interleaveOffset += iBuffer;
                    }
                    
                    vDSP_vfix16(sm.outData+interleaveOffset, sm.numOutputChannels, (SInt16 *)ioData->mBuffers[iBuffer].mData+iChannel, thisNumChannels, inNumberFrames);
                }
            }
            
        }
    }
    
    return noErr;
    
}

#pragma mark - Audio Session Listeners
void sessionPropertyListener(void *                  inClientData,
							 AudioSessionPropertyID  inID,
							 UInt32                  inDataSize,
							 const void *            inData){
	
    // Determines the reason for the route change, to ensure that it is not
    //      because of a category change.
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue ((CFDictionaryRef)inData, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    if (inID == kAudioSessionProperty_AudioRouteChange && routeChangeReason != kAudioSessionRouteChangeReason_CategoryChange)
    {
        AudioManager *sm = (__bridge AudioManager *)inClientData;
        [sm checkSessionProperties];
    }
    
}

- (void)checkAudioSource {
    
    OSStatus result = noErr;

    UInt32 speakerRoute = kAudioSessionOverrideAudioRoute_Speaker;
    UInt32 dataSize = sizeof(speakerRoute);
    result = AudioSessionSetProperty (
                                      // This requires iPhone OS 3.1
                                      kAudioSessionProperty_OverrideCategoryDefaultToSpeaker,
                                      dataSize,
                                      &speakerRoute
                                      );
    
    
    // Check what the incoming audio route is.
    UInt32 propertySize = sizeof(CFStringRef);
    CFStringRef route;
    CheckError( AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route), "Couldn't check the audio route");
    self.inputRoute = (__bridge NSString *)route;
    CFRelease(route);
    NSLog(@"AudioRoute: %@", self.inputRoute);

    // Check if there's input available.
    // TODO: check if checking for available input is redundant.
    //          Possibly there's a different property ID change?
    UInt32 isInputAvailable = 0;
    UInt32 size = sizeof(isInputAvailable);
    CheckError( AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable,
                                        &size,
                                        &isInputAvailable), "Couldn't check if input is available");
    self.inputAvailable = (BOOL)isInputAvailable;
    NSLog(@"Input available? %d", self.inputAvailable);
    
}

- (void)checkSessionProperties
{
    
    // Check if there is input, and from where
    [self checkAudioSource];
    
    // Check the number of input channels.
    // Find the number of channels
    UInt32 size = sizeof(self.numInputChannels);
    UInt32 newNumChannels;
    CheckError( AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, &size, &newNumChannels), "Checking number of input channels");
    self.numInputChannels = newNumChannels;
    //    self.numInputChannels = 1;
    NSLog(@"We've got %lu input channels", self.numInputChannels);
    
    
    // Check the number of input channels.
    // Find the number of channels
    CheckError( AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputNumberChannels, &size, &newNumChannels), "Checking number of output channels");
    self.numOutputChannels = newNumChannels;
    //    self.numOutputChannels = 1;
    NSLog(@"We've got %lu output channels", self.numOutputChannels);
    
    
    // Get the hardware sampling rate. This is settable, but here we're only reading.
    Float64 currentSamplingRate;
    size = sizeof(currentSamplingRate);
    CheckError( AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &size, &currentSamplingRate), "Checking hardware sampling rate");
    self.samplingRate = currentSamplingRate;
    NSLog(@"Current sampling rate: %f", self.samplingRate);
	
}

void sessionInterruptionListener(void *inClientData, UInt32 inInterruption) {
    
	AudioManager *sm = (__bridge AudioManager *)inClientData;
    
	if (inInterruption == kAudioSessionBeginInterruption) {
		NSLog(@"Begin interuption");
		sm.inputAvailable = NO;
	}
	else if (inInterruption == kAudioSessionEndInterruption) {
		NSLog(@"End interuption");
		sm.inputAvailable = YES;
		[sm play];
	}
	
}

@end
