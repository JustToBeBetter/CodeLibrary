#使用方法 终端进入shell所在目录 sh shell.sh执行

if [ ! -d ./IPADir ];
    then
        mkdir -p IPADir;
fi

#工程绝对路径
project_path=$(cd `dirname $0`; pwd)

#工程名 将XXX替换成自己的工程名
project_name=CodeLibrary

#scheme名 将XXX替换成自己的sheme名
scheme_name=CodeLibrary

#打包模式 Debug/Release
development_mode=Debug

#文件夹名称
file_name=`date +%Y-%m-%d-%H-%M-%S`

#build文件夹路径
build_path=~/desktop/build

#plist文件所在路径
exportOptionsPlistPath=${project_path}/exportTest.plist

#导出.ipa文件所在路径
exportIpaPath=~/desktop/IPADir/${development_mode}/${file_name}

if false; then
echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc] "

##
read number
    while([[ $number != 1 ]] && [[ $number != 2 ]])
    do
        echo "Error! Should enter 1 or 2"
        echo "Place enter the number you want to export ? [ 1:app-store 2:ad-hoc] "
        read number
    done

if [ $number == 1 ];
    then
    development_mode=Release
    exportOptionsPlistPath=${project_path}/exportAppstore.plist
## 证书名字

    else
    development_mode=Debug
    exportOptionsPlistPath=${project_path}/exportTest.plist

fi
fi
development_mode=Debug
exportOptionsPlistPath=${project_path}/exportTest.plist


echo '///-----------'
echo '/// 正在清理工程'
echo '///-----------'
xcodebuild \
clean -configuration ${development_mode} -quiet  || exit


echo '///--------'
echo '/// 清理完成'
echo '///--------'
echo ''

echo '///-----------'
echo '/// 正在编译工程:'${development_mode}
echo '///-----------'
xcodebuild \
archive -workspace ${project_path}/${project_name}.xcworkspace \
-scheme ${scheme_name} \
-configuration ${development_mode} \
-archivePath ${build_path}/${project_name}.xcarchive -quiet  || exit

echo '///--------'
echo '/// 编译完成'
echo '///--------'
echo ''

echo '///----------'
echo '/// 开始ipa打包'
echo '///----------'
xcodebuild -exportArchive -archivePath ${build_path}/${project_name}.xcarchive \
-configuration ${development_mode} \
-exportPath ${exportIpaPath} \
-exportOptionsPlist ${exportOptionsPlistPath} \
-quiet || exit

if [ -e $exportIpaPath/$scheme_name.ipa ];
    then
    echo '///----------'
    echo '/// ipa包已导出'
    echo '///----------'
    open $exportIpaPath
    else
    echo '///-------------'
    echo '/// ipa包导出失败 '
    echo '///-------------'
fi
echo '///------------'
echo '/// 打包ipa完成  '
echo '///-----------='
echo ''

echo '///-------------'
echo '/// 开始发布ipa包 '
echo '///-------------'

if false; then
if [ $number == 1 ];
    then

    #验证并上传到App Store

    altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"
    "$altoolPath" --validate-app -f ${exportIpaPath}/${scheme_name}.ipa -u 开发者账号 -p 开发者账号密码 -t ios --output-format xml
    "$altoolPath" --upload-app -f ${exportIpaPath}/${scheme_name}.ipa -u  开发者账号 -p 开发者账号密码 -t ios --output-format xml
else

    echo "Place enter the number you want to export ? [ 1:fir 2:蒲公英] "
    ##
    read platform
        while([[ $platform != 1 ]] && [[ $platform != 2 ]])
        do
            echo "Error! Should enter 1 or 2"
            echo "Place enter the number you want to export ? [ 1:fir 2:蒲公英] "
            read platform
        done

            if [ $platform == 1 ];
                then
                #上传到Fir
                # 将XXX替换成自己的Fir平台的token
                fir login -T xxx
                fir publish $exportIpaPath/$scheme_name.ipa
            else
                echo "开始上传到蒲公英"
                #上传到蒲公英
                #蒲公英aipKey
                MY_PGY_API_K=175b62a4d7f1636f5283305d7a8797a0
                #蒲公英uKey
                MY_PGY_UK=ea3aaa881e13bcc9a278f88cd958912f

                curl -F "file=@${exportIpaPath}/${scheme_name}.ipa" -F "uKey=${MY_PGY_UK}" -F "_api_key=${MY_PGY_API_K}" https://qiniu-storage.pgyer.com/apiv1/app/upload
            fi
fi

fi
echo "开始上传到蒲公英"
#上传到蒲公英
#蒲公英aipKey
MY_PGY_API_K=175b62a4d7f1636f5283305d7a8797a0
#蒲公英uKey
MY_PGY_UK=ea3aaa881e13bcc9a278f88cd958912f

curl -F "file=@${exportIpaPath}/${scheme_name}.ipa" -F "uKey=${MY_PGY_UK}" -F "_api_key=${MY_PGY_API_K}" https://qiniu-storage.pgyer.com/apiv1/app/upload

echo "\n\n"
echo "已运行完毕>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
exit 0


