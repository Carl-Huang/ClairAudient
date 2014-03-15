//
//  MusicMixerOutput.m
//  Record_Mix_Play
//
//  Created by vedon on 4/1/14.
//  Copyright (c) 2014 com.vedon. All rights reserved.
//

#import "MusicMixerOutput.h"
#import <AVFoundation/AVFoundation.h>
@implementation MusicMixerOutput

+(void)appendAudioFile:(NSString *)filePath toFile:(NSString *)appendedFile compositionPath:(NSString *)compositionPath compositionTimes:(NSInteger)times withCompletedBlock:(void (^)(NSError * error,BOOL isFinish))block
{
    AVMutableComposition * composition = [AVMutableComposition composition];
    AVMutableCompositionTrack * compoitionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVURLAsset * originalAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:appendedFile] options:nil];
    AVURLAsset * newAsset       = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:filePath] options:nil];
    
    AVAssetTrack * originalAudioTrack = [[originalAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    AVAssetTrack * newAssetAudioTrack = [[newAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    
    NSError * error = nil;
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, originalAsset.duration);
    [compoitionTrack insertTimeRange:timeRange
                                ofTrack:originalAudioTrack
                                 atTime:kCMTimeZero
                                  error:&error];
    
    if (error)
    {
        block(error,NO);
    }
    
    
    CMTime startTime = originalAsset.duration;
    CMTimeRange newAssetTimeRange = CMTimeRangeMake(kCMTimeZero, newAsset.duration);
    for (int i = 1; i < times; i++) {
        
        [compoitionTrack insertTimeRange:newAssetTimeRange
                                 ofTrack:newAssetAudioTrack
                                  atTime:originalAsset.duration
                                   error:&error];
        startTime = CMTimeAdd(startTime, newAsset.duration);
    }
    
    if (error)
    {
        block(error,NO);
    }
    AVAssetExportSession* exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetPassthrough];
    

    exportSession.outputURL = [NSURL fileURLWithPath:compositionPath];
    exportSession.outputFileType = @"com.apple.quicktime-movie";
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        // exported successfully?
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                block(nil,YES);
            }
                
                // you should now have the appended audio file
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            default:
                break;
        }
        
    }];
    
    originalAsset   = nil;
    newAsset        = nil;
}


+(void)MixingAudioFile:(NSString *)sourceA withFile:(NSString *)sourceB destinatedPath:(NSString *)compositionPath  withCompletedBlock:(void (^)(NSError * error,BOOL isFinish))block
{
    AVMutableComposition * composition = [AVMutableComposition composition];
    AVMutableCompositionTrack * compoitionTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVURLAsset * originalAsset  = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:sourceB] options:nil];
    AVURLAsset * newAsset       = [[AVURLAsset alloc]initWithURL:[NSURL fileURLWithPath:sourceA] options:nil];
    
    AVAssetTrack * originalAudioTrack = [[originalAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    AVAssetTrack * newAssetAudioTrack = [[newAsset tracksWithMediaType:AVMediaTypeAudio]objectAtIndex:0];
    
    NSError * error = nil;
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, originalAsset.duration);
    [compoitionTrack insertTimeRange:timeRange
                             ofTrack:originalAudioTrack
                              atTime:kCMTimeZero
                               error:&error];
    
    if (error)
    {
        block(error,NO);
    }

    
    CMTimeRange newAssetTimeRange = CMTimeRangeMake(kCMTimeZero, newAsset.duration);
    [compoitionTrack insertTimeRange:newAssetTimeRange
                                 ofTrack:newAssetAudioTrack
                                  atTime:kCMTimeZero
                                   error:&error];
    
    if (error)
    {
        block(error,NO);
    }
    
    AVAssetExportSession* exportSession = [AVAssetExportSession
                                           exportSessionWithAsset:composition
                                           presetName:AVAssetExportPresetPassthrough];
    
    NSURL * file = [NSURL fileURLWithPath:compositionPath];
    exportSession.outputURL = file;
    exportSession.outputFileType = @"com.apple.quicktime-movie";
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        
        // exported successfully?
        switch (exportSession.status)
        {
            case AVAssetExportSessionStatusFailed:
                break;
            case AVAssetExportSessionStatusCompleted:
            {
                block(nil,YES);
            }
                
                // you should now have the appended audio file
                break;
            case AVAssetExportSessionStatusWaiting:
                break;
            default:
                break;
        }
        
    }];
    
    originalAsset   = nil;
    newAsset        = nil;
}

+ (OSStatus)mixAudio:(NSString *)audioPath1
            andAudio:(NSString *)audioPath2
              toFile:(NSString *)outputPath
  preferedSampleRate:(float)sampleRate
  withCompletedBlock:(void (^)(id object ,NSError * error))completedBlock
{
    
    OSStatus                                err = noErr;
    //输入文件的描述
    AudioStreamBasicDescription            inputFileFormat1;
    AudioStreamBasicDescription            inputFileFormat2;
    
    //转换文件的描述
    AudioStreamBasicDescription            converterFormat;
    //描述文件结构体的大小
    UInt32                                AudioStreamBasicDescriptionSize = sizeof(AudioStreamBasicDescription);
    
    ExtAudioFileRef                        inputAudioFileRef1 = NULL;
    ExtAudioFileRef                        inputAudioFileRef2 = NULL;
    ExtAudioFileRef                        outputAudioFileRef = NULL;
    AudioStreamBasicDescription            outputFileFormat;
    
    NSURL *inURL1 = [NSURL fileURLWithPath:audioPath1];
    NSURL *inURL2 = [NSURL fileURLWithPath:audioPath2];
    NSURL *outURL = [NSURL fileURLWithPath:outputPath];
    
    
    
    UInt16 bufferSize = 8192;
    AudioSampleType * buffer1 = malloc(bufferSize);
    AudioSampleType * buffer2 = malloc(bufferSize);
    AudioSampleType * outBuffer = malloc(bufferSize);
    // Open input audio file
    
    err = ExtAudioFileOpenURL((__bridge CFURLRef)inURL1, &inputAudioFileRef1);
    if (err)
    {
        goto reterr;
    }
    
    assert(inputAudioFileRef1);
    
    err = ExtAudioFileOpenURL((__bridge CFURLRef)inURL2, &inputAudioFileRef2);
    if (err)
    {
        goto reterr;
    }
    assert(inputAudioFileRef2);
    
    // 获取输入文件1格式
    bzero(&inputFileFormat1, sizeof(inputFileFormat1));
    err = ExtAudioFileGetProperty(inputAudioFileRef1, kExtAudioFileProperty_FileDataFormat,
                                  &AudioStreamBasicDescriptionSize, &inputFileFormat1);
    if (err)
    {
        goto reterr;
    }
    
    if (inputFileFormat1.mChannelsPerFrame > 2)
    {
        err = kExtAudioFileError_InvalidDataFormat;
        goto reterr;
    }
    
    // 获取输入文件2格式
    bzero(&inputFileFormat2, sizeof(inputFileFormat2));
    err = ExtAudioFileGetProperty(inputAudioFileRef2, kExtAudioFileProperty_FileDataFormat,
                                  &AudioStreamBasicDescriptionSize, &inputFileFormat2);
    if (err)
    {
        goto reterr;
    }
    
    if (inputFileFormat2.mChannelsPerFrame > 2)
    {
        err = kExtAudioFileError_InvalidDataFormat;
        goto reterr;
    }
    
    int numChannels = MAX(inputFileFormat1.mChannelsPerFrame, inputFileFormat2.mChannelsPerFrame);
    
    // Enable an audio converter on the input audio data by setting
    // the kExtAudioFileProperty_ClientDataFormat property. Each
    // read from the input file returns data in linear pcm format.
    
    AudioFileTypeID audioFileTypeID = kAudioFileCAFType;
    
    Float64 mSampleRate = sampleRate? sampleRate : MAX(inputFileFormat1.mSampleRate, inputFileFormat2.mSampleRate);
    
    [self _setDefaultAudioFormatFlags:&converterFormat sampleRate:mSampleRate numChannels:inputFileFormat1.mChannelsPerFrame];
    
    err = ExtAudioFileSetProperty(inputAudioFileRef1, kExtAudioFileProperty_ClientDataFormat,
                                  sizeof(converterFormat), &converterFormat);
    if (err)
    {
        goto reterr;
    }
    [self _setDefaultAudioFormatFlags:&converterFormat sampleRate:mSampleRate numChannels:inputFileFormat2.mChannelsPerFrame];
    err = ExtAudioFileSetProperty(inputAudioFileRef2, kExtAudioFileProperty_ClientDataFormat,
                                  sizeof(converterFormat), &converterFormat);
    if (err)
    {
        goto reterr;
    }
    // Handle the case of reading from a mono input file and writing to a stereo
    // output file by setting up a channel map. The mono output is duplicated
    // in the left and right channel.
    
    if (inputFileFormat1.mChannelsPerFrame == 1 && numChannels == 2) {
        SInt32 channelMap[2] = { 0, 0 };
        
        // Get the underlying AudioConverterRef
        
        AudioConverterRef convRef = NULL;
        UInt32 size = sizeof(AudioConverterRef);
        
        err = ExtAudioFileGetProperty(inputAudioFileRef1, kExtAudioFileProperty_AudioConverter, &size, &convRef);
        
        if (err)
        {
            goto reterr;
        }
        
        assert(convRef);
        
        err = AudioConverterSetProperty(convRef, kAudioConverterChannelMap, sizeof(channelMap), channelMap);
        
        if (err)
        {
            goto reterr;
        }
    }
    if (inputFileFormat2.mChannelsPerFrame == 1 && numChannels == 2) {
        SInt32 channelMap[2] = { 0, 0 };
        
        // Get the underlying AudioConverterRef
        
        AudioConverterRef convRef = NULL;
        UInt32 size = sizeof(AudioConverterRef);
        
        err = ExtAudioFileGetProperty(inputAudioFileRef2, kExtAudioFileProperty_AudioConverter, &size, &convRef);
        
        if (err)
        {
            goto reterr;
        }
        
        assert(convRef);
        
        err = AudioConverterSetProperty(convRef, kAudioConverterChannelMap, sizeof(channelMap), channelMap);
        
        if (err)
        {
            goto reterr;
        }
    }
    // Output file is typically a caff file, but the user could emit some other
    // common file types. If a file exists already, it is deleted before writing
    // the new audio file.
    
    [self _setDefaultAudioFormatFlags:&outputFileFormat sampleRate:mSampleRate numChannels:numChannels];
    
    UInt32 flags = kAudioFileFlags_EraseFile;
    
    err = ExtAudioFileCreateWithURL((__bridge CFURLRef)outURL, audioFileTypeID, &outputFileFormat,
                                    NULL, flags, &outputAudioFileRef);
    if (err)
    {
        // -48 means the file exists already
        goto reterr;
    }
    assert(outputAudioFileRef);
    
    // Enable converter when writing to the output file by setting the client
    // data format to the pcm converter we created earlier.
    
    //    err = ExtAudioFileSetProperty(outputAudioFileRef, kExtAudioFileProperty_ClientDataFormat,
    //                                  sizeof(outputFileFormat), &outputFileFormat);
    if (err)
    {
        goto reterr;
    }
    
    // Buffer to read from source file and write to dest file
    
    
    AudioBufferList conversionBuffer1;
    conversionBuffer1.mNumberBuffers = 1;
    conversionBuffer1.mBuffers[0].mNumberChannels = inputFileFormat1.mChannelsPerFrame;
    conversionBuffer1.mBuffers[0].mDataByteSize = bufferSize;
    conversionBuffer1.mBuffers[0].mData = buffer1;
    
    AudioBufferList conversionBuffer2;
    conversionBuffer2.mNumberBuffers = 1;
    conversionBuffer2.mBuffers[0].mNumberChannels = inputFileFormat2.mChannelsPerFrame;
    conversionBuffer2.mBuffers[0].mDataByteSize = bufferSize;
    conversionBuffer2.mBuffers[0].mData = buffer2;
    
    //
    AudioBufferList outBufferList;
    outBufferList.mNumberBuffers = 1;
    outBufferList.mBuffers[0].mNumberChannels = outputFileFormat.mChannelsPerFrame;
    outBufferList.mBuffers[0].mDataByteSize = bufferSize;
    outBufferList.mBuffers[0].mData = outBuffer;
    
    UInt32 numFramesToReadPerTime = INT_MAX;
    int cont = sizeof(AudioSampleType);
    UInt8 bitOffset = 8 * sizeof(AudioSampleType);
    UInt64 bitMax = (UInt64) (pow(2, bitOffset));
    UInt64 bitMid = bitMax/2;
    
    
    while (TRUE) {
        conversionBuffer1.mBuffers[0].mDataByteSize = bufferSize;
        conversionBuffer2.mBuffers[0].mDataByteSize = bufferSize;
        outBufferList.mBuffers[0].mDataByteSize = bufferSize;
        
        UInt32 frameCount1 = numFramesToReadPerTime;
        UInt32 frameCount2 = numFramesToReadPerTime;
        
        if (inputFileFormat1.mBytesPerFrame)
        {
            frameCount1 = bufferSize/inputFileFormat1.mBytesPerFrame;
        }
        if (inputFileFormat2.mBytesPerFrame)
        {
            frameCount2 = bufferSize/inputFileFormat2.mBytesPerFrame;
        }
        // Read a chunk of input
        
        err = ExtAudioFileRead(inputAudioFileRef1, &frameCount1, &conversionBuffer1);
        
        if (err) {
            goto reterr;
        }
        
        err = ExtAudioFileRead(inputAudioFileRef2, &frameCount2, &conversionBuffer2);
        
        if (err) {
            goto reterr;
        }
        // If no frames were returned, conversion is finished
        
        if (frameCount1 == 0 && frameCount2 == 0)
            break;
        
        UInt32 frameCount = MAX(frameCount1, frameCount2);
        UInt32 minFrames = MIN(frameCount1, frameCount2);
        
        outBufferList.mBuffers[0].mDataByteSize = frameCount * outputFileFormat.mBytesPerFrame;
        
        UInt32 length = frameCount * 2;
        for (int j =0; j < length; j++)
        {
            if (j/2 < minFrames)
            {
                SInt32 sValue =0;
                
                SInt16 value1 = (SInt16)*(buffer1+j);   //-32768 ~ 32767
                SInt16 value2 = (SInt16)*(buffer2+j);   //-32768 ~ 32767
                
                SInt8 sign1 = (value1 == 0)? 0 : abs(value1)/value1;
                SInt8 sign2 = (value2== 0)? 0 : abs(value2)/value2;
                
                if (sign1 == sign2)
                {
                    UInt32 tmp = ((value1 * value2) >> (bitOffset -1));
                    
                    sValue = value1 + value2 - sign1 * tmp;
                    
                    if (abs(sValue) >= bitMid)
                    {
                        sValue = sign1 * (bitMid -  1);
                    }
                }
                else
                {
                    SInt32 tmpValue1 = value1 + bitMid;
                    SInt32 tmpValue2 = value2 + bitMid;
                    
                    UInt32 tmp = ((tmpValue1 * tmpValue2) >> (bitOffset -1));
                    
                    if (tmpValue1 < bitMid && tmpValue2 < bitMid)
                    {
                        sValue = tmp;
                    }
                    else
                    {
                        sValue = 2 * (tmpValue1  + tmpValue2 ) - tmp - bitMax;
                    }
                    sValue -= bitMid;
                }
                
                if (abs(sValue) >= bitMid)
                {
                    SInt8 sign = abs(sValue)/sValue;
                    
                    sValue = sign * (bitMid -  1);
                }
                *(outBuffer +j) = sValue;
            }
            else{
                if (frameCount == frameCount1)
                {
                    //将buffer1中的剩余数据添加到outbuffer
                    *(outBuffer +j) = *(buffer1 + j);
                }
                else
                {
                    //将buffer1中的剩余数据添加到outbuffer
                    *(outBuffer +j) = *(buffer2 + j);
                }
            }
        }
        
        // Write pcm data to output file
        NSLog(@"frame count (%ld, %ld, %ld)", frameCount, frameCount1, frameCount2);
        err = ExtAudioFileWrite(outputAudioFileRef, frameCount, &outBufferList);
        
        if (err) {
            goto reterr;
        }
    }

    
reterr:
    if (err != 0) {
        completedBlock(nil,[NSError errorWithDomain:@"不支持格式" code:1000 userInfo:nil]);
    }else
    {
        completedBlock(nil,nil);
    }
    
    if (buffer1)
        free(buffer1);
    
    if (buffer2)
        free(buffer2);
    
    if (outBuffer)
        free(outBuffer);
    
    if (inputAudioFileRef1)
        ExtAudioFileDispose(inputAudioFileRef1);
    
    if (inputAudioFileRef2)
        ExtAudioFileDispose(inputAudioFileRef2);
    
    if (outputAudioFileRef)
        ExtAudioFileDispose(outputAudioFileRef);
    
    return err;
}

+ (void) _setDefaultAudioFormatFlags:(AudioStreamBasicDescription*)audioFormatPtr
                          sampleRate:(Float64)sampleRate
                         numChannels:(NSUInteger)numChannels
{
    bzero(audioFormatPtr, sizeof(AudioStreamBasicDescription));
    
    audioFormatPtr->mFormatID = kAudioFormatLinearPCM;
    audioFormatPtr->mSampleRate = sampleRate;
    audioFormatPtr->mChannelsPerFrame = numChannels;
    audioFormatPtr->mBytesPerPacket = 2 * numChannels;
    audioFormatPtr->mFramesPerPacket = 1;
    audioFormatPtr->mBytesPerFrame = 2 * numChannels;
    audioFormatPtr->mBitsPerChannel = 16;
    audioFormatPtr->mFormatFlags = kAudioFormatFlagsNativeEndian |
    kAudioFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;
}
@end
