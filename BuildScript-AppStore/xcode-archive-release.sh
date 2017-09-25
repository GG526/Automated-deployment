#!/bin/sh
#

#rvm system

# xcodebuild -list



now=$(date +"%Y-%m-%d-%H-%M-%S")
archiveName="HqpAppStore_${now}"
projectName="DDQP-Swift.xcodeproj"
scheme="DDQP-Swift-appstore"
codeSignIdentity="iPhone Distribution: Shangzer Infomation Inc. (2LHX2V2ZTT)"
appStoreProvisioningProfile="fcf75260-90a0-49cf-a2da-87bfe50c0017"
configuration="AppStore"
exportOptionsPlist="BuildScript-AppStore/release_exportOptions.plist"
buildPath=$(dirname $(PWD))
# buildPath=$(dirname ${buildPath})
ipaPath="${buildPath}/appStorebuild/${archiveName}/${scheme}.ipa"
appleid="xixi917@gmail.com"
applepassword="raymOnd917"

LOGIN_PASSWORD="123456"
LOGIN_KEYCHAIN=~/Library/Keychains/login.keychain

function failed() {
    echo "Failed: $@" >&2
    rm -rf $PWD/build
    exit 1
}

osascript -e 'display notification "Release To AppStore" with title "Running"'

osascript -e 'display notification "Release To AppStore" with title "git更新"'
git reset --hard || failed "清除本地失败1"
git clean -xdf  || failed "清除本地失败2"
git pull origin master || failed "更新git失败"

# security unlock-keychain -p ${LOGIN_PASSWORD} ${LOGIN_KEYCHAIN}

#build clean
osascript -e 'display notification "Release To AppStore" with title "Clean Complete!"'
xcodebuild clean -project ${projectName} \
				 -configuration ${configuration} \
				 -alltargets || failed "clean error"



#打包 archive
osascript -e 'display notification "Release To AppStore" with title "Archive Complete!"'
xcodebuild archive -project ${projectName} \
					-configuration ${configuration} \
					-scheme ${scheme} \
					-destination generic/platform=iOS \
					-archivePath $PWD/build/${archiveName}.xcarchive || failed "archive error"




#导出到ipa
osascript -e 'display notification "Release To AppStore" with title "Export Complete!"'
xcodebuild -exportArchive -archivePath $PWD/build/${archiveName}.xcarchive \
		 	-exportOptionsPlist ${exportOptionsPlist} \
		 	-exportPath ${buildPath}/appStorebuild/${archiveName} \
		 	-verbose || failed "export error"



###################################
#发布到iTunesConnect
###################################
osascript -e 'display notification "Release To AppStore" with title "开始提交到App Store"'
altoolPath="/Applications/Xcode.app/Contents/Applications/Application Loader.app/Contents/Frameworks/ITunesSoftwareService.framework/Versions/A/Support/altool"

#validate
osascript -e 'display notification "Release To AppStore" with title "Validate Complete!"'
"${altoolPath}" --validate-app -f ${ipaPath} -u "$appleid" -p "$applepassword" -t ios --output-format xml || failed "validate error"

#upload
osascript -e 'display notification "Release To AppStore" with title "Upload Complete!"'
"${altoolPath}" --upload-app -f ${ipaPath} -u "$appleid" -p "$applepassword" -t ios --output-format xml || failed "upload error"

#删除build文件夹
osascript -e 'display notification "Release To AppStore" with title "rm build"'
rm -rf $PWD/build || failed "删除build文件夹失败"

osascript -e 'display notification "Release To AppStore" with title "完成"'
