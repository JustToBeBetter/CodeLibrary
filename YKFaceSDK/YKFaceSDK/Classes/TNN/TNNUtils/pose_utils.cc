//
// Created by feng on 5/14/21.
//

#include "pose_utils.h"
#include "opencv2/core/core.hpp"
#include "opencv2/opencv.hpp"
#include <math.h>

Quaterniond estimateHeadPose(std::vector<std::pair<float, float>> &key_points, int width, int height) {
    // 对应Dlib上点的序号为18, 22, 23, 27, 37, 40, 43, 46, 32, 36, 49, 55, 58, 9
    if (key_points.size() <= 0) {
        return Quaterniond();
    }
    std::vector<cv::Point3d> model_points;

    model_points.push_back(cv::Point3d(6.825897f, 6.760612f, 4.402142f));
    model_points.push_back(cv::Point3d(1.330353f, 7.122144f, 6.903745f));
    model_points.push_back(cv::Point3d(-1.330353f, 7.122144f, 6.903745f));
    model_points.push_back(cv::Point3d(-6.825897f, 6.760612f, 4.402142f));
    model_points.push_back(cv::Point3d(5.311432f, 5.485328f, 3.987654f));
    model_points.push_back(cv::Point3d(1.789930f, 5.393625f, 4.413414f));

    model_points.push_back(cv::Point3d(-1.789930f, 5.393625f, 4.413414f));
    model_points.push_back(cv::Point3d(-5.311432f, 5.485328f, 3.987654f));
    model_points.push_back(cv::Point3d(2.005628f, 1.409845f, 6.165652f));
    model_points.push_back(cv::Point3d(-2.005628f, 1.409845f, 6.165652f));
    model_points.push_back(cv::Point3d(2.774015f, -2.080775f, 5.048531f));
    model_points.push_back(cv::Point3d(-2.774015f, -2.080775f, 5.048531f));

    model_points.push_back(cv::Point3d(0.000000f, -3.116408f, 6.097667f));
    model_points.push_back(cv::Point3d(0.000000f, -7.415691f, 4.070434f));

    // 对应优图270上点的序号为0, 4, 12, 8, 16, 20, 28, 24, 41, 45, 54, 60, 57, 96
    std::vector<cv::Point2d> landmarks_c; //
    std::vector<int> points{0, 4, 12, 8, 16, 20, 28, 24, 41, 45, 54, 60, 57, 96};
    int point = 0;
    for (int i = 0; i < points.size(); i++) {
        point = points[i];

        landmarks_c.push_back(cv::Point2d(key_points[point].first, key_points[point].second));
    }

    double focal_length = width; // Approximate focal length.
    cv::Point2d center = cv::Point2d(width / 2, height / 2);
    cv::Mat camera_matrix = (cv::Mat_<double>(3, 3) << focal_length, 0, center.x, 0, focal_length, center.y, 0, 0, 1);
    cv::Mat dist_coeffs = cv::Mat::zeros(4, 1, cv::DataType<double>::type); // Assuming no lens distortion

    cv::Mat rotation_vector; // Rotation in axis-angle form
    cv::Mat translation_vector;

    // Solve for pose
    cv::solvePnP(model_points, landmarks_c, camera_matrix, dist_coeffs, rotation_vector, translation_vector);

    //calculate rotation angles
    double theta = cv::norm(rotation_vector, cv::NORM_L2);

    //transformed to quaterniond
    Quaterniond q;
    q.w = cos(theta / 2);
    q.x = sin(theta / 2)*rotation_vector.at<double>(0, 0) / theta;
    q.y = sin(theta / 2)*rotation_vector.at<double>(0, 1) / theta;
    q.z = sin(theta / 2)*rotation_vector.at<double>(0, 2) / theta;

    double ysqr = q.y * q.y;

    // pitch (x-axis rotation)
    double t0 = +2.0 * (q.w * q.x + q.y * q.z);
    double t1 = +1.0 - 2.0 * (q.x * q.x + ysqr);
    q.pitch = std::atan2(t0, t1);

    // yaw (y-axis rotation)
    double t2 = +2.0 * (q.w * q.y - q.z * q.x);
    t2 = t2 > 1.0 ? 1.0 : t2;
    t2 = t2 < -1.0 ? -1.0 : t2;
    q.yaw = std::asin(t2);

    // roll (z-axis rotation)
    double t3 = +2.0 * (q.w * q.z + q.x * q.y);
    double t4 = +1.0 - 2.0 * (ysqr + q.z * q.z);
    q.roll = std::atan2(t3, t4);
    return q;
}
