//
//  OVRLispHelper.cpp
//  LipSyncTest
//
//  Created by 李金柱 on 2022/1/10.
//
#include "OVRLispHelper.hpp"
#include "pch.h"
#include "OVRLispSync.h"

#define NUM_CHANNELS 2
#define SAMPLE_RATE 16000
#define BLOCK_SIZE 480

unsigned int CurrentContext = 0;

// Wav Header
struct wav_header_t
{
    char chunkID[4]; //"RIFF" = 0x46464952
    unsigned long chunkSize; //28 [+ sizeof(wExtraFormatBytes) + wExtraFormatBytes] + sum(sizeof(chunk.id) + sizeof(chunk.size) + chunk.size)
    char format[4]; //"WAVE" = 0x45564157
    char subchunk1ID[4]; //"fmt " = 0x20746D66
    unsigned long subchunk1Size; //16 [+ sizeof(wExtraFormatBytes) + wExtraFormatBytes]
    unsigned short audioFormat;
    unsigned short numChannels;
    unsigned long sampleRate;
    unsigned long byteRate;
    unsigned short blockAlign;
    unsigned short bitsPerSample;
    //[WORD wExtraFormatBytes;]
    //[Extra format bytes]
};

//Chunks
struct chunk_t
{
    char ID[4]; //"data" = 0x61746164
    unsigned long size;  //Chunk data bytes
};


void process_wav(unsigned int CurrentContext,const char *filePath)
{

    FILE* fin = fopen(filePath, "rb");

    //Read WAV header
    wav_header_t header;
    fread(&header, sizeof(header), 1, fin);

    //Print WAV header
    printf("WAV File Header read:\n");
    printf("File Type: %s\n", header.chunkID);
    printf("File Size: %ld\n", header.chunkSize);
    printf("WAV Marker: %s\n", header.format);
    printf("Format Name: %s\n", header.subchunk1ID);
    printf("Format Length: %ld\n", header.subchunk1Size);
    printf("Format Type: %hd\n", header.audioFormat);
    printf("Number of Channels: %hd\n", header.numChannels);
    printf("Sample Rate: %ld\n", header.sampleRate);
    printf("Sample Rate * Bits/Sample * Channels / 8: %ld\n", header.byteRate);
    printf("Bits per Sample * Channels / 8.1: %hd\n", header.blockAlign);
    printf("Bits per Sample: %hd\n", header.bitsPerSample);


    //Reading file
    chunk_t chunk;
    printf("id\t" "size\n");
    //go to data chunk
//    while (true)
//    {
//        fread(&chunk, sizeof(chunk), 1, fin);
////        printf("%c%c%c%c\t" "%li\n", chunk.ID[0], chunk.ID[1], chunk.ID[2], chunk.ID[3], chunk.size);
//        if (*(unsigned int*)&chunk.ID == 0x61746164){
//            printf("7788999\n");
//            break;
//        }
//           
//        //skip chunk data bytes
//        fseek(fin, chunk.size, SEEK_CUR);
//    }


    //Number of samples
    int sample_size = header.bitsPerSample / 8;
    int samples_count = chunk.size * 8 / header.bitsPerSample;
    printf("Samples count = %i\n", samples_count);

    int16_t* value = new int16_t[samples_count];
    memset(value, 0, sizeof(int16_t) * samples_count);

    //Reading data
    for (int i = 0; i < samples_count; i++) {
        fread(&value[i], sample_size, 1, fin);
    }

    int32_t sample_index = 0;
    int32_t left_sample = samples_count;
    float SampleBuffer[VISEME_SAMPLES * 2];

    while (left_sample > 0) {
        int32_t process_sample = left_sample < VISEME_SAMPLES ? left_sample : VISEME_SAMPLES;
        for (int32_t i = 0; i < process_sample; i++)
        {
            int16_t Sample = value[sample_index + i];
            SampleBuffer[i * 2] = Sample / (float)SHRT_MAX;
            SampleBuffer[i * 2 + 1] = Sample / (float)SHRT_MAX;
        }

        FOVRLipSyncFrame TempFrame;
        FOVRLipSync::ProcessFrameEx(CurrentContext, SampleBuffer, ovrLipSyncFlag::None, &TempFrame);

        for (int i = 0; i < TempFrame.Visemes.size(); i++) {
            printf("%f ", TempFrame.Visemes[i]);
        }
        printf("\n");

        sample_index += process_sample;
        left_sample -= process_sample;
    }

    fclose(fin);
}
bool OVRLispHelper::StartupModule()
{
    return FOVRLipSync::StartupModule();
}

void OVRLispHelper::Initialize()
{
    FOVRLipSync::Initialize();
}

int OVRLispHelper::IsInitialized()
{
    return  FOVRLipSync::IsInitialized();
}

void OVRLispHelper::Shutdown()
{
    if (CurrentContext) {
        FOVRLipSync::DestroyContext(CurrentContext);
    }
    FOVRLipSync::Shutdown();
}
void OVRLispHelper::StartSDK(){
    setlocale(LC_CTYPE, "chs");
    ovrLipSyncContextProvider ContextProvider = ovrLipSyncContextProvider::Other;
    FOVRLipSync::StartupModule();
    FOVRLipSync::Initialize();
    FOVRLipSync::CreateContext(&CurrentContext, ContextProvider);
}
void OVRLispHelper::Start(const char *filePath)
{
    setlocale(LC_CTYPE, "chs");

    unsigned int CurrentContext = 0;
    ovrLipSyncContextProvider ContextProvider = ovrLipSyncContextProvider::Main;

    FOVRLipSync::StartupModule();
    FOVRLipSync::Initialize();

    FOVRLipSync::CreateContext(&CurrentContext, ContextProvider);

    process_wav(CurrentContext,filePath);

    if (CurrentContext) {
        FOVRLipSync::DestroyContext(CurrentContext);
    }
}


int OVRLispHelper::ProcessAudioData(void *buffer)
{
    
    int visemesIndex = 0;
    int samples_count = 1024;
//    printf("Samples count = %i\n", samples_count);

    int16_t* value = new int16_t[samples_count];
    value = (int16_t *)buffer;
 
    int32_t sample_index = 0;
    int32_t left_sample = samples_count;
    float SampleBuffer[VISEME_SAMPLES * 2];

    while (left_sample > 0) {
        int32_t process_sample = left_sample < VISEME_SAMPLES ? left_sample : VISEME_SAMPLES;
        for (int32_t i = 0; i < process_sample; i++)
        {
            int16_t Sample = value[sample_index + i];
            SampleBuffer[i * 2] = Sample / (float)SHRT_MAX;
            SampleBuffer[i * 2 + 1] = Sample / (float)SHRT_MAX;
        }

        FOVRLipSyncFrame TempFrame;
        FOVRLipSync::ProcessFrameEx(CurrentContext, SampleBuffer, ovrLipSyncFlag::None, &TempFrame);

        for (int i = 0; i < TempFrame.Visemes.size(); i++) {
            //口型概率 所有口型概率总和为1
            float probability = TempFrame.Visemes[i];
            if (probability) {
//                printf("%d %f ",i,TempFrame.Visemes[i]);
            }
            if (probability > 0.5) {
                visemesIndex = i;
                break;
            }
            if (probability > TempFrame.Visemes[visemesIndex]) {
                visemesIndex = i;
            }
        }
        sample_index += process_sample;
        left_sample -= process_sample;
    }
//    printf("visemesIndex %d \n",visemesIndex);
    return visemesIndex;
}
