# 定义工程目录地址
path_project=$(dirname "$0")
# 定义编译地址
path_build=$path_project"/build"
path_ReleaseiPhoneos=$path_build"/Release-iphoneos"
path_ReleaseSimulator=$path_build"/Release-iphonesimulator"
# 定义打包目标地址
path_destination=$(dirname $(dirname "$0"))
# 切换到工程目录
cd $path_project
# 清理build并删除build文件夹
xcodebuild -alltargets clean
rm -rf $path_build
echo "Clean并删除Build目录"

# 编译普通版本的Target
xcodebuild OTHER_CFLAGS="-fembed-bitcode" -target YiJiaBundleAd -configuration Release -sdk iphoneos -arch armv7 -arch arm64
xcodebuild -target YiJiaBundleAd -configuration Release -sdk iphonesimulator -arch i386 -arch x86_64
echo "Target build完毕"

## 创建SDK目录
#mkdir $path_destination

# 普通版本
rm -rf $path_destination"/libYiJiaBundleAd"
mv $path_ReleaseiPhoneos"/libYiJiaBundleAd" $path_destination"/libYiJiaBundleAd"
lipo -create $path_ReleaseiPhoneos"/libYiJiaBundleAd.a" $path_ReleaseSimulator"/libYiJiaBundleAd.a" -output $path_destination"/libYiJiaBundleAd/libYiJiaBundleAd.a"
echo "打包完毕"
lipo -info $path_destination"/libYiJiaBundleAd/libYiJiaBundleAd.a"

# 打包完毕，清理build并删除build文件夹
xcodebuild -alltargets clean
rm -rf $path_build
echo "Clean并删除Build目录"

