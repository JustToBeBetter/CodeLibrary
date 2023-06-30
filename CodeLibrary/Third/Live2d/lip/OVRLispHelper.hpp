//
//  OVRLispHelper.hpp
//  LipSyncTest
//
//  Created by 李金柱 on 2022/1/10.
//

#ifndef OVRLispHelper_hpp
#define OVRLispHelper_hpp

#include <stdio.h>


class OVRLispHelper
{

public:
    static bool StartupModule();
    static void Initialize();
    static int IsInitialized();
    static void Shutdown();
    static void StartSDK();
    static void Start(const char *filePath);
    static int ProcessAudioData(void *buffer);

};


#endif /* OVRLispHelper_hpp */



