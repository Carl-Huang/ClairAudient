//
//  AudioReader.m
//  Audio_HelloWorld
//
//  Created by vedon on 7/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "AudioReader.h"
@interface AudioReader()
{
    RingBuffer * ringBuffer;
}
@property (nonatomic, copy, readwrite)   NSURL *audioFileURL;
@property (nonatomic, assign, readwrite, getter=getDuration) float duration;
@property (nonatomic, assign, readwrite) float samplingRate;
@property (nonatomic, assign, readwrite) UInt32 numChannels;
@property (nonatomic, assign, readwrite) BOOL playing;

@property (nonatomic, assign) AudioStreamBasicDescription outputFormat;
@property (nonatomic, assign) ExtAudioFileRef inputFile;
@property (nonatomic, assign) UInt32 outputBufferSize;
@property (nonatomic, assign) float *outputBuffer;
@property (nonatomic, assign) float *holdingBuffer;
@property (nonatomic, assign) UInt32 numSamplesReadPerPacket;
@property (nonatomic, assign) UInt32 desiredPrebufferedSamples;
@property (nonatomic, assign) SInt64 currentFileTime;
@property (nonatomic, assign) dispatch_source_t callbackTimer;


- (void)bufferNewAudio;


@end

@implementation AudioReader
- (id)initWithAudioFileURL:(NSURL *)urlToAudioFile samplingRate:(float)thisSamplingRate numChannels:(UInt32)thisNumChannels
{
    self = [super init];
    if (self)
    {
        self.callbackTimer = nil;
        
        // Open a reference to the audio file
        self.audioFileURL = urlToAudioFile;
        CFURLRef audioFileRef = (__bridge CFURLRef)self.audioFileURL;
        CheckError(ExtAudioFileOpenURL(audioFileRef, &_inputFile), "Opening file URL (ExtAudioFileOpenURL)");
        
        
        // Set a few defaults and presets
        self.samplingRate = thisSamplingRate;
        self.numChannels = thisNumChannels;
        self.latency = .011609977; // 512 samples / ( 44100 samples / sec ) default
        
        _outputFormat.mSampleRate = self.samplingRate;
        _outputFormat.mFormatID = kAudioFormatLinearPCM;
        _outputFormat.mFormatFlags = kAudioFormatFlagIsFloat;
        _outputFormat.mBytesPerPacket = 4*self.numChannels;
        _outputFormat.mFramesPerPacket = 1;
        _outputFormat.mBytesPerFrame = 4*self.numChannels;
        _outputFormat.mChannelsPerFrame = self.numChannels;
        _outputFormat.mBitsPerChannel = 32;
        ExtAudioFileSetProperty(_inputFile, kExtAudioFileProperty_ClientDataFormat, sizeof(AudioStreamBasicDescription), &_outputFormat);
        self.outputBufferSize = 65536;
        self.numSamplesReadPerPacket = 8192;
        self.desiredPrebufferedSamples = self.numSamplesReadPerPacket*2;
        self.outputBuffer = (float *)calloc(2*self.samplingRate, sizeof(float));
        self.holdingBuffer = (float *)calloc(2*self.samplingRate, sizeof(float));
        
        ringBuffer = new RingBuffer(self.outputBufferSize, self.numChannels);
        
        
        // Fill up the buffers, so we're ready to play immediately
        [self bufferNewAudio];
        
    }
    return self;
}

- (void)clearBuffer
{
    ringBuffer->Clear();
}

- (void)bufferNewAudio
{
    
    if (ringBuffer->NumUnreadFrames() > self.desiredPrebufferedSamples)
        return;
    
    memset(self.outputBuffer, 0, sizeof(float)*self.desiredPrebufferedSamples);
    
    AudioBufferList incomingAudio;
    incomingAudio.mNumberBuffers = 1;
    incomingAudio.mBuffers[0].mNumberChannels = self.numChannels;
    incomingAudio.mBuffers[0].mDataByteSize = self.outputBufferSize;
    incomingAudio.mBuffers[0].mData = self.outputBuffer;
    
    // Figure out where we are in the file
    SInt64 frameOffset = 0;
    ExtAudioFileTell(self.inputFile, &frameOffset);
    self.currentFileTime = (float)frameOffset / self.samplingRate;
    
    // Read the audio
    UInt32 framesRead = self.numSamplesReadPerPacket;
    ExtAudioFileRead(self.inputFile, &framesRead, &incomingAudio);
    
    // Update where we are in the file
    ExtAudioFileTell(self.inputFile, &frameOffset);
    self.currentFileTime = (float)frameOffset / self.samplingRate;
    
    // Add the new audio to the ring buffer
    ringBuffer->AddNewInterleavedFloatData(self.outputBuffer, framesRead, self.numChannels);
    
    if ((self.currentFileTime - self.duration) < 0.01 && framesRead == 0) {
        // modified to allow for auto-stopping. //
        // Need to change your output block to check for [fileReader playing] and nuke your fileReader if it is   //
        // not playing and not paused, on the next frame. Otherwise, the sound clip's final buffer is not played. //
        //        self.currentTime = 0.0f;
        [self stop];
        ringBuffer->Clear();
    }
    
    
}

- (float)getCurrentTime
{
    return self.currentFileTime - ringBuffer->NumUnreadFrames()/self.samplingRate;
}


- (void)setCurrentTime:(float)thisCurrentTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self pause];
        ExtAudioFileSeek(self.inputFile, thisCurrentTime*self.samplingRate);
        
        [self clearBuffer];
        [self bufferNewAudio];
        
        [self play];
    });
}

- (float)getDuration
{
    // We're going to directly calculate the duration of the audio file (in seconds)
    SInt64 framesInThisFile;
    UInt32 propertySize = sizeof(framesInThisFile);
    ExtAudioFileGetProperty(self.inputFile, kExtAudioFileProperty_FileLengthFrames, &propertySize, &framesInThisFile);
    
    AudioStreamBasicDescription fileStreamFormat;
    propertySize = sizeof(AudioStreamBasicDescription);
    ExtAudioFileGetProperty(self.inputFile, kExtAudioFileProperty_FileDataFormat, &propertySize, &fileStreamFormat);
    
    return (float)framesInThisFile/(float)fileStreamFormat.mSampleRate;
    
}

- (void)configureReaderCallback
{
    if (!self.callbackTimer)
    {
        self.callbackTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        UInt32 numSamplesPerCallback = (UInt32)( self.latency * self.samplingRate );
        dispatch_source_set_timer(self.callbackTimer, dispatch_walltime(NULL, 0), self.latency*NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(self.callbackTimer, ^{
            
            if (self.playing) {
                
                if (self.readerBlock) {
                    // Suck some audio down from our ring buffer
                    [self retrieveFreshAudio:self.holdingBuffer numFrames:numSamplesPerCallback numChannels:self.numChannels];
                    
                    // Call out with the audio that we've got.
                    self.readerBlock(self.holdingBuffer, numSamplesPerCallback, self.numChannels);
                }
                
                // Asynchronously fill up the buffer (if it needs filling)
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self bufferNewAudio];
                });
                
            }
            
        });
        
        dispatch_resume(self.callbackTimer);
    }
}


- (void)retrieveFreshAudio:(float *)buffer numFrames:(UInt32)thisNumFrames numChannels:(UInt32)thisNumChannels
{
    ringBuffer->FetchInterleavedData(buffer, thisNumFrames, thisNumChannels);
    if ([self.delegate respondsToSelector:@selector(currentFileLocation:)]) {
        [self.delegate currentFileLocation:[self getCurrentTime]];
    }
}


- (void)play
{
    // Configure (or if necessary, create and start) the timer for retrieving audio
    if (!self.playing) {
        [self configureReaderCallback];
        self.playing = TRUE;
    }
    
}

- (void)pause
{
    // Pause the dispatch timer for retrieving the MP3 audio
    self.playing = FALSE;
}

- (void)stop
{
    // Release the dispatch timer because it holds a reference to this class instance
    [self pause];
    if (self.callbackTimer ) {
        dispatch_release(self.callbackTimer);
    }
}

- (void)dealloc
{
    // If the dispatch timer is active, close it off
    free(self.outputBuffer);
    free(self.holdingBuffer);
    if (self.playing)
        [self pause];
    
    self.readerBlock = nil;
    
    // Close the ExtAudioFile
    ExtAudioFileDispose(self.inputFile);

    delete ringBuffer;
    [super dealloc];
}
@end
