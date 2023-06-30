
#include "pch.h"
#include "OVRLispSync.h"

#define LOCTEXT_NAMESPACE _T("OVRLipSync.dll")


int FOVRLipSync::sOVRLipSyncInit = -1;


dll_ovrlipsyncInitialize FOVRLipSync::OVRLipSyncInitialize = NULL;
dll_ovrlipsyncShutdown FOVRLipSync::OVRLipSyncShutdown = NULL;
dll_ovrlipsyncGetVersion FOVRLipSync::OVRLipSyncGetVersion = NULL;
dll_ovrlipsyncCreateContext FOVRLipSync::OVRLipSyncCreateContext = NULL;
dll_ovrlipsyncDestroyContext FOVRLipSync::OVRLipSyncDestroyContext = NULL;
dll_ovrlipsyncResetContext FOVRLipSync::OVRLipSyncResetContext = NULL;
dll_ovrlipsyncSendSignal FOVRLipSync::OVRLipSyncSendSignal = NULL;
dll_ovrlipsyncProcessFrame FOVRLipSync::OVRLipSyncProcessFrame = NULL;
dll_ovrlipsyncProcessFrameInterleaved FOVRLipSync::OVRLipSyncProcessFrameInterleaved = NULL;
dll_ovrlispSyncProcessFrameEx FOVRLipSync::OVRLipSyncProcessFrameEx = NULL;


//void PrintLastError(const std::wstring& err_cause)
//{
//	DWORD errorMessageID = ::GetLastError();
//	TCHAR *messageBuffer = nullptr;
//	size_t size = FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
//		NULL, errorMessageID,
//		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
//		(TCHAR*)&messageBuffer,
//		0,
//		NULL);
//
//	_tprintf(_T("%s error:%d desc:%s \n"), err_cause.c_str(), errorMessageID, messageBuffer);
//	LocalFree(messageBuffer);
//}

//void* GetDllExport(void * hModule,  char funcName)
//{
//	void* dllFunc =  GetProcAddress(hModule, funcName);
//	if (dllFunc == NULL) {
//		std::wostringstream os;
//		os << _T("GetDllExport ") << funcName << _T(" failed.");
//		PrintLastError(os.str());
//	}
//
//	return dllFunc;
//}



bool FOVRLipSync::StartupModule()
{
    void *ovrLispModule = dlopen("libOVRLipSync.dylib", RTLD_NOW);
    if (!ovrLispModule) {
        printf("OVRLisploaderror \n");
    }

	OVRLipSyncInitialize = (dll_ovrlipsyncInitialize) dlsym(ovrLispModule, "ovrLipSyncDll_Initialize");
	OVRLipSyncShutdown = (dll_ovrlipsyncShutdown) dlsym(ovrLispModule, "ovrLipSyncDll_Shutdown");
	OVRLipSyncGetVersion = (dll_ovrlipsyncGetVersion) dlsym(ovrLispModule, "ovrLipSyncDll_GetVersion");
	OVRLipSyncCreateContext = (dll_ovrlipsyncCreateContext) dlsym(ovrLispModule, "ovrLipSyncDll_CreateContext");
	OVRLipSyncDestroyContext = (dll_ovrlipsyncDestroyContext) dlsym(ovrLispModule, "ovrLipSyncDll_DestroyContext");
	OVRLipSyncResetContext = (dll_ovrlipsyncResetContext) dlsym(ovrLispModule, "ovrLipSyncDll_ResetContext");
	OVRLipSyncSendSignal = (dll_ovrlipsyncSendSignal) dlsym(ovrLispModule, "ovrLipSyncDll_SendSignal");
	OVRLipSyncProcessFrame = (dll_ovrlipsyncProcessFrame) dlsym(ovrLispModule, "ovrLipSyncDll_ProcessFrame");
	OVRLipSyncProcessFrameInterleaved = (dll_ovrlipsyncProcessFrameInterleaved) dlsym(ovrLispModule, "ovrLipSyncDll_ProcessFrameInterleaved");
	OVRLipSyncProcessFrameEx = (dll_ovrlispSyncProcessFrameEx)dlsym(ovrLispModule, "ovrLipSyncDll_ProcessFrameEx");

	return true;
}


void FOVRLipSync::Initialize()
{
	sOVRLipSyncInit = OVRLipSyncInitialize(VOICE_SAMPLE_RATE, VISEME_SAMPLES);
	
	int major, minor, patch;
	OVRLipSyncGetVersion(&major, &minor, &patch);
	printf("OVRLispVersion %d.%d.%d \n", major, minor, patch);
}

int FOVRLipSync::IsInitialized()
{
	return sOVRLipSyncInit;
}

void FOVRLipSync::Shutdown()
{
	OVRLipSyncShutdown();
}

int FOVRLipSync::CreateContext(unsigned int* Context, ovrLipSyncContextProvider Provider)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::CannotCreateContext;

	return OVRLipSyncCreateContext(Context, Provider);
}

int FOVRLipSync::DestroyContext(unsigned int Context)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	return OVRLipSyncDestroyContext(Context);
}

int FOVRLipSync::ResetContext(unsigned int Context)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	return OVRLipSyncResetContext(Context);
}

int FOVRLipSync::SendSignal(unsigned int Context, ovrLipSyncSignals Signal, int Arg1, int Arg2)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	return OVRLipSyncSendSignal(Context, Signal, Arg1, Arg2);
}

int FOVRLipSync::ProcessFrame(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	// this function has some bugs(version 1.0.1), so use OVRLipSyncProcessFrameInterleaved instead
	return OVRLipSyncProcessFrame(Context, AudioBuffer, Flags, &Frame->FrameNumber, &Frame->FrameDelay, Frame->Visemes.data(), Frame->Visemes.size());
}

int FOVRLipSync::ProcessFrameInterleaved(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	return OVRLipSyncProcessFrameInterleaved(Context, AudioBuffer, Flags, &Frame->FrameNumber, &Frame->FrameDelay, Frame->Visemes.data(), Frame->Visemes.size());
}

int FOVRLipSync::ProcessFrameEx(unsigned int Context, float* AudioBuffer, ovrLipSyncFlag Flags, FOVRLipSyncFrame* Frame)
{
	if (IsInitialized() != ovrLipSyncSuccess)
		return (int)ovrLipSyncError::Unknown;

	float laughterScore = 0;
	// this function has some bugs(version 1.0.1), so use OVRLipSyncProcessFrameInterleaved instead
	return OVRLipSyncProcessFrameEx(Context, AudioBuffer, 1024, F32_Stereo, &Frame->FrameNumber, &Frame->FrameDelay, Frame->Visemes.data(), Frame->Visemes.size(), &laughterScore, NULL, 0);
}
