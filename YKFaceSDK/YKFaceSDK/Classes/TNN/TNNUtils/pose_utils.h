//
// Created by feng on 5/14/21.
//

#ifndef PROJ_ANDROID_CMAKE_POSE_UTILS_H
#define PROJ_ANDROID_CMAKE_POSE_UTILS_H

#include <vector>

typedef struct Quaterniond {
    float w;
    float x;
    float y;
    float z;
    float yaw;
    float roll;
    float pitch;
} Quaterniond;

Quaterniond estimateHeadPose(std::vector<std::pair<float, float>> &key_points, int width, int height);

#endif //PROJ_ANDROID_CMAKE_POSE_UTILS_H
