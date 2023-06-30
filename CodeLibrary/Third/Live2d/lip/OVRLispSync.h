#pragma once

#define VOICE_SAMPLE_RATE	16000
#define VISEME_SAMPLES		1024
#define VISEME_BUF_SIZE		2048

// Audio buffer data type
enum AudioDataType
{
	// Signed 16-bit integer mono audio stream
	S16_Mono,
	// Signed 16-bit integer stereo audio stream
	S16_Stereo,
	// Signed 32-bit float mono audio stream
	F32_Mono,
	// Signed 32-bit float stereo audio stream
	F32_Stereo
};

typedef int(*dll_ovrlipsyncInitialize)(int, int);
typedef void(*dll_ovrlipsyncShutdown)(void);
typedef int(*dll_ovrlipsyncGetVersion)(int*, int*, int*);
typedef int(*dll_ovrlipsyncCreateContext)(unsigned int*, int);
typedef int(*dll_ovrlipsyncDestroyContext)(unsigned int);
typedef int(*dll_ovrlipsyncResetContext)(unsigned int);
typedef int(*dll_ovrlipsyncSendSignal)(unsigned int, int, int, int);
typedef int(*dll_ovrlipsyncProcessFrame)(unsigned int, float*, int, int*, int*, float*, int);
typedef int(*dll_ovrlipsyncProcessFrameInterleaved)(unsigned int, float*, int, int*, int*, float*, int);
typedef int(*dll_ovrlispSyncProcessFrameEx)(unsigned int context,
	float* audioBuffer,
	unsigned int bufferSize,
	AudioDataType dataType,
	int* frameNumber,
	int* frameDelay,
	float* visemes,
	int visemeCount,
	float* laughterScore,
	float* laughterCategories,
	int laughterCategoriesLength);

// Various visemes
enum ovrLipSyncViseme
{
	sil,
	PP,
	FF,
	TH,
	DD,
	kk,
	CH,
	SS,
	nn,
	RR,
	aa,
	E,
	ih,
	oh,
	ou,
	VisemesCount
};


// Enum for provider context to create
enum ovrLipSyncContextProvider
{
	Main,
	Other
};


// Error codes that may return from Lip-Sync engine
enum ovrLipSyncError
{
	Unknown = -2200,	//< An unknown error has occurred
	CannotCreateContext = -2201, 	//< Unable to create a context
	InvalidParam = -2202,	//< An invalid parameter, e.g. NULL pointer or out of range
	BadSampleRate = -2203,	//< An unsupported sample rate was declared
	MissingDLL = -2204,	//< The DLL or shared library could not be found
	BadVersion = -2205,	//< Mismatched versions between header and libs
	UndefinedFunction = -2206	//< An undefined function
};

/// Flags
enum ovrLipSyncFlag
{
	None = 0x0000,
	DelayCompensateAudio = 0x0001

};

// Enum for sending lip-sync engine specific signals
enum ovrLipSyncSignals
{
	VisemeOn,
	VisemeOff,
	VisemeAmount,
	VisemeSmoothing,
	SignalCount
};

#define ovrLipSyncSuccess 0

struct FOVRLipSyncFrame
{

	FOVRLipSyncFrame()
	{
		FrameNumber = 0;
		FrameDelay = 0;

		for (int i = 0; i < (int)ovrLipSyncViseme::VisemesCount; i++) {
			Visemes.push_back(0.f);
		}
	}

	FOVRLipSyncFrame& operator=(const FOVRLipSyncFrame& Other)
	{
		FrameNumber = Other.FrameNumber;
		FrameDelay = Other.FrameDelay;
		Visemes = Other.Visemes;

		return *this;
	}

	int FrameNumber; 			// count from start of recognition
	int FrameDelay;  			// in ms
	std::vector<float> Visemes;	// Array of floats for viseme frame. Size of Viseme Count, above
};


class FOVRLipSync
{
	static int sOVRLipSyncInit;

public:
	static bool StartupModule();
	static void Initialize();
	static int IsInitialized();
	static void Shutdown();

	static int CreateContext(unsigned int* Context, ovrLipSyncContextProvider Provider);
	static int DestroyContext(unsigned int Context);
	static int ResetContext(unsigned int Context);
	static int SendSignal(unsigned int Context, ovrLipSyncSignals Signal, int Arg1, int Arg2);
	static int ProcessFrame(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame);
	static int ProcessFrameInterleaved(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame);
	static int ProcessFrameEx(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame);

public:
	static dll_ovrlipsyncInitialize OVRLipSyncInitialize;
	static dll_ovrlipsyncShutdown OVRLipSyncShutdown;
	static dll_ovrlipsyncGetVersion OVRLipSyncGetVersion;
	static dll_ovrlipsyncCreateContext OVRLipSyncCreateContext;
	static dll_ovrlipsyncDestroyContext OVRLipSyncDestroyContext;
	static dll_ovrlipsyncResetContext OVRLipSyncResetContext;
	static dll_ovrlipsyncSendSignal OVRLipSyncSendSignal;
	static dll_ovrlipsyncProcessFrame OVRLipSyncProcessFrame;
	static dll_ovrlipsyncProcessFrameInterleaved OVRLipSyncProcessFrameInterleaved;
	static dll_ovrlispSyncProcessFrameEx OVRLipSyncProcessFrameEx;
};
