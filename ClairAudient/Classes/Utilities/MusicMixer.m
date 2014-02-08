//
//  MusicMixer.m
//  Record_Mix_Play
//
//  Created by vedon on 3/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MusicMixer.h"
#import <CoreAudio/CoreAudioTypes.h>

MusicMixer *audioUnitHelper;

static void SilenceData(AudioBufferList *inData)
{
	for (UInt32 i=0; i < inData->mNumberBuffers; i++)
		memset(inData->mBuffers[i].mData, 0, inData->mBuffers[i].mDataByteSize);
}

// audio render procedure to render our client data format
// 2 ch 'lpcm' 16-bit little-endian signed integer interleaved this is mClientFormat data, see CAStreamBasicDescription SetCanonical()
static OSStatus renderInput(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    
    AudioSampleType *in  = userData->soundBuffer[inBusNumber].data;
    AudioSampleType *out = (AudioSampleType *)ioData->mBuffers[0].mData;
    
    UInt32 sample = userData->frameNum * userData->soundBuffer[inBusNumber].asbd.mChannelsPerFrame;
    
    // make sure we don't attempt to render more data than we have available in the source buffers
    // if one buffer is larger than the other, just render silence for that bus until we loop around again
    if ((userData->frameNum + inNumberFrames) > userData->soundBuffer[inBusNumber].numFrames) {
        UInt32 offset = (userData->frameNum + inNumberFrames) - userData->soundBuffer[inBusNumber].numFrames;
        if (offset < inNumberFrames) {
            // copy the last bit of source
            SilenceData(ioData);
            memcpy(out, &in[sample], ((inNumberFrames - offset) * userData->soundBuffer[inBusNumber].asbd.mBytesPerFrame));
            return noErr;
        } else {
            // got no source data
            SilenceData(ioData);
            *ioActionFlags |= kAudioUnitRenderAction_OutputIsSilence;
            return noErr;
        }
    }
	
    memcpy(out, &in[sample], ioData->mBuffers[0].mDataByteSize);

    AudioBufferList tempAudioList;
    tempAudioList.mNumberBuffers = 1;
    tempAudioList.mBuffers[0].mNumberChannels = 1;
    tempAudioList.mBuffers[0].mDataByteSize = ioData->mBuffers[0].mDataByteSize;
    tempAudioList.mBuffers[0].mData = out;
//
    [audioUnitHelper processAudio:&tempAudioList withNum:inNumberFrames];
    
    printf("render input bus %ld sample %ld\n", inBusNumber, sample);
    
    return noErr;
}
static OSStatus renderNotification(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber, UInt32 inNumberFrames, AudioBufferList *ioData)
{
    SourceAudioBufferDataPtr userData = (SourceAudioBufferDataPtr)inRefCon;
    
    if (*ioActionFlags & kAudioUnitRenderAction_PostRender) {
        
        //printf("post render notification frameNum %ld inNumberFrames %ld\n", userData->frameNum, inNumberFrames);
        
        userData->frameNum += inNumberFrames;
        if (userData->frameNum >= userData->maxNumFrames) {
            userData->frameNum = 0;
        }
    }
    
    return noErr;
}
@interface MusicMixer ()

- (void)loadFiles;

@end

@implementation MusicMixer
@synthesize mIsPlaying;
@synthesize mEQPresetsArray;

- (void)dealloc
{
    printf("AUGraphController dealloc\n");
    
    DisposeAUGraph(mGraph);
    
    free(mUserData.soundBuffer[0].data);
    free(mUserData.soundBuffer[1].data);
    
    CFRelease(sourceURL[0]);
    CFRelease(sourceURL[1]);
    
    CFRelease(mEQPresetsArray);
    
	[super dealloc];
}


- (void)initializeAUGraph
{
    p =(struct AudioBufferListArray *) malloc(sizeof(AudioBufferListArray));
    p ->pNext = NULL;
    p ->numFrame = 0;
//    memset(p->audioData, 0, sizeof(AudioBufferList));
    head = q = p ;
    
    audioUnitHelper = self;
  	mIsPlaying = false;
    
    // clear the mSoundBuffer struct
	memset(&mUserData.soundBuffer, 0, sizeof(mUserData.soundBuffer));
    // create the URLs we'll use for source A and B
    NSString *sourceA = [[NSBundle mainBundle] pathForResource:@"dongxiaojie1" ofType:@"mp3"];
    NSString *sourceB = [[NSBundle mainBundle] pathForResource:@"dongxiaojie2" ofType:@"mp3"];
    sourceURL[0] = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)sourceA, kCFURLPOSIXPathStyle, false);
    sourceURL[1] = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)sourceB, kCFURLPOSIXPathStyle, false);
    
    printf("initializeAUGraph\n");
    AUNode outputNode;
    AUNode eqNode;
	AUNode mixerNode;
    
    printf("create client ASBD\n");
    
    // client format audio goes into the mixer
    [self setDefaultAudioFormatFlags:&mClientFormat sampleRate:VAudioSampleRate numChannels:2 interleaved:YES];

    
    // output format
    [self setOutputDefaultAudioFormatFlags:&mOutputFormat sampleRate:VAudioSampleRate numChannels:2 interleaved:NO];

	OSStatus result = noErr;
    
    // load up the audio data
    [self performSelectorInBackground:@selector(loadFiles) withObject:nil];
    
    printf("new AUGraph\n");
    
    // create a new AUGraph
	result = NewAUGraph(&mGraph);
    if (result) { printf("NewAUGraph result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    // create three CAComponentDescription for the AUs we want in the graph
    AudioComponentDescription output_desc;
    AudioComponentDescription eq_desc;
    AudioComponentDescription mixer_desc;
    
    output_desc.componentType = kAudioUnitType_Output;
    output_desc.componentSubType = kAudioUnitSubType_RemoteIO;
    output_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    output_desc.componentFlags = 0;
    output_desc.componentFlagsMask = 0;
    
    eq_desc.componentType = kAudioUnitType_Effect;
    eq_desc.componentSubType = kAudioUnitSubType_AUiPodEQ;
    eq_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    eq_desc.componentFlags = 0;
    eq_desc.componentFlagsMask = 0;
    
    mixer_desc.componentType = kAudioUnitType_Mixer;
    mixer_desc.componentSubType = kAudioUnitSubType_MultiChannelMixer;
    mixer_desc.componentManufacturer = kAudioUnitManufacturer_Apple;
    mixer_desc.componentFlags = 0;
    mixer_desc.componentFlagsMask = 0;

 
    
    printf("add nodes\n");
    
    // create a node in the graph that is an AudioUnit, using the supplied AudioComponentDescription to find and open that unit
	result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
	if (result) { printf("AUGraphNewNode 1 result %lu %4.4s\n", result, (char*)&result); return; }
    
    result = AUGraphAddNode(mGraph, &eq_desc, &eqNode);
    if (result) { printf("AUGraphNewNode 2 result %lu %4.4s\n", result, (char*)&result); return; }
    
	result = AUGraphAddNode(mGraph, &mixer_desc, &mixerNode);
	if (result) { printf("AUGraphNewNode 3 result %lu %4.4s\n", result, (char*)&result); return; }
    
    // connect a node's output to a node's input
    // mixer -> eq -> output
    result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, eqNode, 0);
	if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
	
    result = AUGraphConnectNodeInput(mGraph, eqNode, 0, outputNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %lu %4.4s\n", result, (char*)&result); return; }
    
    // open the graph AudioUnits are open but not initialized (no resource allocation occurs here)
	result = AUGraphOpen(mGraph);
	if (result) { printf("AUGraphOpen result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	
    // grab the audio unit instances from the nodes
	result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &mMixer);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(mGraph, eqNode, NULL, &mEQ);
    if (result) { printf("AUGraphNodeInfo result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    // set bus count
	UInt32 numbuses = 2;
	
    printf("set input bus count %lu\n", numbuses);
	
    result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
	for (int i = 0; i < numbuses; ++i) {
		// setup render callback struct
		AURenderCallbackStruct rcbs;
		rcbs.inputProc = &renderInput;
		rcbs.inputProcRefCon = &mUserData;
        
        printf("set AUGraphSetNodeInputCallback\n");
        
        // set a callback for the specified node's specified input
        result = AUGraphSetNodeInputCallback(mGraph, mixerNode, i, &rcbs);
        if (result) { printf("AUGraphSetNodeInputCallback result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
		
		printf("set input bus %d, client kAudioUnitProperty_StreamFormat\n", i);
        
        // set the input stream format, this is the format of the audio for mixer input
		result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &mClientFormat, sizeof(mClientFormat));
        if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	}
    
    printf("get EQ kAudioUnitProperty_FactoryPresets\n");
    
    // get the eq's factory preset list -- this is a read-only CFArray array of AUPreset structures
    // host owns the retuned array and should release it when no longer needed
    UInt32 size = sizeof(mEQPresetsArray);
    result = AudioUnitGetProperty(mEQ, kAudioUnitProperty_FactoryPresets, kAudioUnitScope_Global, 0, &mEQPresetsArray, &size);
    if (result) { printf("AudioUnitGetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    /* this code can be used if you're interested in dumping out the preset list
     printf("iPodEQ Factory Preset List:\n");
     UInt8 count = CFArrayGetCount(mEQPresetsArray);
     for (int i = 0; i < count; ++i) {
     AUPreset *aPreset = (AUPreset*)CFArrayGetValueAtIndex(mEQPresetsArray, i);
     CFShow(aPreset->presetName);
     }*/
    
    printf("set output kAudioUnitProperty_StreamFormat\n");
    
    // set the output stream format of the mixer
	result = AudioUnitSetProperty(mMixer, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &mOutputFormat, sizeof(mOutputFormat));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    printf("set render notification\n");
    
    // add a render notification, this is a callback that the graph will call every time the graph renders
    // the callback will be called once before the graph’s render operation, and once after the render operation is complete
    result = AUGraphAddRenderNotify(mGraph, renderNotification, &mUserData);
    if (result) { printf("AUGraphAddRenderNotify result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    printf("AUGraphInitialize\n");
    
    // now that we've set everything up we can initialize the graph, this will also validate the connections
	result = AUGraphInitialize(mGraph);
    if (result) { printf("AUGraphInitialize result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    CAShow(mGraph);
 
    [self setupWriteHelper];
}


//读取文件的内容到buffer 中，用来render Callback 中填充数据
- (void)loadFiles
{
    mUserData.frameNum = 0;
    mUserData.maxNumFrames = 0;
    
    for (int i = 0; i < NUMFILES && i < MAXBUFS; i++)  {
        printf("loadFiles, %d\n", i);
        
        ExtAudioFileRef xafref = 0;
        
        // open one of the two source files
        OSStatus result = ExtAudioFileOpenURL(sourceURL[i], &xafref);
        if (result || !xafref) { printf("ExtAudioFileOpenURL result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        // get the file data format, this represents the file's actual data format
        // for informational purposes only -- the client format set on ExtAudioFile is what we really want back
        AudioStreamBasicDescription fileFormat;
        UInt32 propSize = sizeof(fileFormat);
        
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        printf("file %d, native file format\n", i);
        
        
        // set the client format to be what we want back
        // this is the same format audio we're giving to the the mixer input
        result = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(mClientFormat), &mClientFormat);
        if (result) { printf("ExtAudioFileSetProperty kExtAudioFileProperty_ClientDataFormat %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        // get the file's length in sample frames
        UInt64 numFrames = 0;
        propSize = sizeof(numFrames);
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        if (result) { printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        
        // keep track of the largest number of source frames
        if (numFrames > mUserData.maxNumFrames) mUserData.maxNumFrames = numFrames;
        
        // set up our buffer
        mUserData.soundBuffer[i].numFrames = numFrames;
        mUserData.soundBuffer[i].asbd = mClientFormat;
        
        UInt32 samples = numFrames * mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        mUserData.soundBuffer[i].data = (AudioSampleType *)calloc(samples, sizeof(AudioSampleType));
        
        // set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        bufList.mBuffers[0].mData = mUserData.soundBuffer[i].data;
        bufList.mBuffers[0].mDataByteSize = samples * sizeof(AudioSampleType);
        
        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = numFrames;
        result = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (result) {
            printf("ExtAudioFileRead result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result);
            free(mUserData.soundBuffer[i].data);
            mUserData.soundBuffer[i].data = 0;
            return;
        }
        
        // close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
    }
}
// enable or disables a specific bus
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue
{
    printf("BUS %ld isON %f\n", inputNum, isONValue);
    
    OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isONValue, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
}

// sets the input volume for a specific bus
- (void)setInputVolume:(UInt32)inputNum value:(AudioUnitParameterValue)value
{
	OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Input result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
}

// sets the overall mixer output volume
- (void)setOutputVolume:(AudioUnitParameterValue)value
{
	OSStatus result = AudioUnitSetParameter(mMixer, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Output result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
}

- (void)selectEQPreset:(NSInteger)value;
{
    AUPreset *aPreset = (AUPreset*)CFArrayGetValueAtIndex(mEQPresetsArray, value);
    OSStatus result = AudioUnitSetProperty(mEQ, kAudioUnitProperty_PresentPreset, kAudioUnitScope_Global, 0, aPreset, sizeof(AUPreset));
    if (result) { printf("AudioUnitSetProperty result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; };
    
    printf("SET EQ PRESET %d ", value);
    CFShow(aPreset->presetName);
}

// stars render
- (void)startAUGraph
{
    printf("PLAY\n");
    
	OSStatus result = AUGraphStart(mGraph);
    if (result) { printf("AUGraphStart result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
	mIsPlaying = true;
}

// stops render
- (void)stopAUGraph
{
	printf("STOP\n");
    
    Boolean isRunning = false;
    
    OSStatus result = AUGraphIsRunning(mGraph, &isRunning);
    if (result) { printf("AUGraphIsRunning result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
    
    if (isRunning) {
        result = AUGraphStop(mGraph);
        if (result) { printf("AUGraphStop result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); return; }
        mIsPlaying = false;
    }
    
//    q = head;
//    while (q) {
//        p = q -> pNext;
//        if (q ->numFrame!=0) {
//            ExtAudioFileWrite(extAudioFile, q->numFrame, q->audioData);
//            for (int i = 0; i<q->audioData->mNumberBuffers; i++) {
//                free(q->audioData->mBuffers[i].mData);
//            }
//            free(q->audioData);
//            free(q);
//        }else
//        {
//            free(q);
//        }
//        q = p;
//    }
    @synchronized(self) {
        if (extAudioFile) {
            ExtAudioFileDispose(extAudioFile);
            extAudioFile = NULL;
        }
    }

}


- (void) setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
                         sampleRate:(Float64)sampleRate
                        numChannels:(NSUInteger)numChannels interleaved:(BOOL)interleave
{
    int sampleSize = sizeof(AudioSampleType);
    bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
    
    audioFormatPtr->mFormatID           = kAudioFormatLinearPCM;
    audioFormatPtr->mSampleRate         = sampleRate;
    audioFormatPtr->mChannelsPerFrame   = numChannels;
    audioFormatPtr->mFramesPerPacket    = 1;
    audioFormatPtr->mBitsPerChannel     = 8* sampleSize;
    audioFormatPtr->mFormatFlags        = kAudioFormatFlagsCanonical;
    
    if (interleave)
    {
			audioFormatPtr->mBytesPerPacket = audioFormatPtr->mBytesPerFrame = numChannels * sampleSize;
    }
    else
    {
			audioFormatPtr->mBytesPerPacket = audioFormatPtr->mBytesPerFrame = sampleSize;
			audioFormatPtr->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }

}
- (void) setOutputDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
                         sampleRate:(Float64)sampleRate
                        numChannels:(NSUInteger)numChannels interleaved:(BOOL)interleave
{
    int sampleSize = sizeof(AudioUnitSampleType);
    bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
    
    audioFormatPtr->mFormatID           = kAudioFormatLinearPCM;
    audioFormatPtr->mSampleRate         = sampleRate;
    audioFormatPtr->mChannelsPerFrame   = numChannels;
    audioFormatPtr->mFramesPerPacket    = 1;
    audioFormatPtr->mBitsPerChannel     = 8* sampleSize;
    
    
#if CA_PREFER_FIXED_POINT
    audioFormatPtr->mFormatFlags  = kAudioFormatFlagsCanonical | (kAudioUnitSampleFractionBits << kLinearPCMFormatFlagsSampleFractionShift);
#else
    audioFormatPtr->mFormatFlags  = kAudioFormatFlagsCanonical;
#endif
    
    if (interleave)
    {
        audioFormatPtr->mBytesPerPacket = audioFormatPtr->mBytesPerFrame = numChannels * sampleSize;
    }
    else
    {
        audioFormatPtr->mBytesPerPacket = audioFormatPtr->mBytesPerFrame = sampleSize;
        audioFormatPtr->mFormatFlags |= kAudioFormatFlagIsNonInterleaved;
    }
    
}



- (void) processAudio: (AudioBufferList*) bufferList withNum:(UInt32)numFrame{
    ExtAudioFileWriteAsync(extAudioFile, numFrame, bufferList);
   
//    p =(AudioBufferListArray *) malloc(sizeof(AudioBufferListArray));
//    p -> audioData = (AudioBufferList *)malloc(sizeof(AudioBufferList));
//    
//    
//    if (p!=NULL) {
//        p -> audioData->mNumberBuffers = bufferList->mNumberBuffers;
//        for ( int i=0; i<bufferList->mNumberBuffers; i++ ) {
//            p->audioData->mBuffers[i].mData = malloc(bufferList->mBuffers[i].mDataByteSize);
//            
//            p->audioData->mBuffers[i].mDataByteSize = bufferList->mBuffers[i].mDataByteSize;
//            p->audioData->mBuffers[i].mNumberChannels = bufferList->mBuffers[i].mNumberChannels;
//             memcpy(p->audioData->mBuffers[i].mData, bufferList->mBuffers[i].mData, bufferList->mBuffers[i].mDataByteSize);
//        }
//
//        p -> pNext = NULL;
//        p -> numFrame = numFrame;
//        q -> pNext = p;
//        q = p;
//    }
    
}

-(NSString *)getLocalFilePath
{
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *destinationFilePath = [NSString stringWithFormat: @"%@/AudioRecording.caf", documentsDirectory];
    return destinationFilePath;

}
-(void)setupWriteHelper
{
//    AudioStreamBasicDescription audioFormat;
//    audioFormat.mSampleRate			= 44100;
//	audioFormat.mFormatID			= kAudioFormatLinearPCM;
//	audioFormat.mFormatFlags		= kAudioFormatFlagsCanonical;
//    audioFormat.mBytesPerPacket		= 4;
//	audioFormat.mFramesPerPacket	= 1;
//	audioFormat.mChannelsPerFrame	= 2;
//	audioFormat.mBitsPerChannel		= 16;
//	audioFormat.mBytesPerFrame		= 4;
//    audioFormat.mReserved           = 0;
    NSString * destinationFilePath = [self getLocalFilePath];
    CFURLRef  localFilePath = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)destinationFilePath, kCFURLPOSIXPathStyle, false);
    OSStatus status = ExtAudioFileCreateWithURL(localFilePath,
                                                kAudioFileCAFType,
                                                &mClientFormat,
                                                NULL,
                                                kAudioFileFlags_EraseFile,
                                                &extAudioFile);
    
    
    CheckError(status, "创建文件路径失败");
    if (noErr != status) {
        if (extAudioFile) ExtAudioFileDispose(extAudioFile);
        extAudioFile = NULL;
    }

}

#pragma mark - CheckError
static void CheckError(OSStatus error, const char *operation)
{
	if (error == noErr) return;
	
	char errorString[20];
	// see if it appears to be a 4-char-code
	*(UInt32 *)(errorString + 1) = CFSwapInt32HostToBig(error);
	if (isprint(errorString[1]) && isprint(errorString[2]) && isprint(errorString[3]) && isprint(errorString[4])) {
		errorString[0] = errorString[5] = '\'';
		errorString[6] = '\0';
	} else
		// no, format it as an integer
		sprintf(errorString, "%d", (int)error);
	
	fprintf(stderr, "Error: %s (%s)\n", operation, errorString);
	
	exit(1);
}

@end
