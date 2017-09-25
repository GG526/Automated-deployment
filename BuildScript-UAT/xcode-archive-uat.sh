#!/bin/sh

#rvm system

# xcodebuild -list



now=$(date +"%Y-%m-%d-%H-%M-%S")
archiveName="HqpUAT_${now}"
projectName="DDQP-Swift.xcodeproj"
scheme="DDQP-Swift-pre"
codeSignIdentity="iPhone Distribution: Shangzer Infomation Inc. (2LHX2V2ZTT)"
appStoreProvisioningProfile="fcf75260-90a0-49cf-a2da-87bfe50c0017"
configuration="UAT"
exportOptionsPlist="BuildScript-UAT/uat_exportOptions.plist"
buildPath=$(dirname $(PWD))
# buildPath=$(dirname ${buildPath})
ipaPath="${buildPath}/biaozhunyufaBuild/${archiveName}/${scheme}.ipa"
appleid="xixi917@gmail.com"
applepassword="raymOnd917"

function failed() {
    echo "Failed: $@" >&2
    rm -rf $PWD/build
    exit 1
}

osascript -e 'display notification "标准预发" with title "Running"'

osascript -e 'display notification "标准预发" with title "git更新"'
git reset --hard || failed "清除本地失败1"
git clean -xdf  || failed "清除本地失败2"
git pull origin master || failed "更新git失败"

#build clean
osascript -e 'display notification "标准预发" with title "清理缓存"'
xcodebuild clean -configuration ${configuration} -alltargets || failed "clean error"

#打包 archive
osascript -e 'display notification "标准预发" with title "Archive Complete!"'
xcodebuild archive -project ${projectName} \
					 -scheme ${scheme} -configuration ${configuration} -archivePath $PWD/build/${archiveName}.xcarchive  || failed "archive error"

#导出到ipa
osascript -e 'display notification "标准预发" with title "Export Complete!"'
xcodebuild -exportArchive -archivePath $PWD/build/${archiveName}.xcarchive -exportOptionsPlist ${exportOptionsPlist} -exportPath ${buildPath}/biaozhunyufaBuild/${archiveName} || failed "Export error"


###################################
#发布到蒲公英
###################################
osascript -e 'display notification "标准预发" with title "提交到蒲公英"'
echo "提交蒲公英"
curl -F "file=@${ipaPath}" \
-F "uKey=42288d021768ede10646af9889ab8a2b" \
-F "_api_key=cc16de8a696510ce18ad4b023cfa2a74" \
-F "updateDescription=预发环境" \
https://www.pgyer.com/apiv1/app/upload || failed "提交到蒲公英失败"
echo "上传到蒲公英成功"
echo "Done."
echo "完成"
rm -rf $PWD/build || failed "删除build文件夹失败"
osascript -e 'display notification "标准预发" with title "完成"'
