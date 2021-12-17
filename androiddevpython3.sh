#!/bin/bash

# PYTHON-2
function python_2_script()
{
BUILDOZER_VERSION=0.39
CYTHON_VERSION=0.28.6
ANDROID_HOME="/opt/android"
ANDROID_NDK_HOME="${ANDROID_HOME}/android-ndk"
ANDROID_NDK_VERSION="17c"
ANDROID_NDK_HOME_V="${ANDROID_NDK_HOME}-r${ANDROID_NDK_VERSION}"

# get the latest version from https://developer.android.com/ndk/downloads/index.html
ANDROID_NDK_ARCHIVE="android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip"
ANDROID_NDK_DL_URL="https://dl.google.com/android/repository/${ANDROID_NDK_ARCHIVE}"


ANDROID_SDK_HOME="${ANDROID_HOME}/android-sdk"

# get the latest version from https://developer.android.com/studio/index.html
ANDROID_SDK_TOOLS_VERSION="4333796"
ANDROID_SDK_BUILD_TOOLS_VERSION="28.0.3"
ANDROID_SDK_TOOLS_ARCHIVE="sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip"
ANDROID_SDK_TOOLS_DL_URL="https://dl.google.com/android/repository/${ANDROID_SDK_TOOLS_ARCHIVE}"


APACHE_ANT_VERSION="1.9.4"
APACHE_ANT_ARCHIVE="apache-ant-${APACHE_ANT_VERSION}-bin.tar.gz"
APACHE_ANT_DL_URL="http://archive.apache.org/dist/ant/binaries/${APACHE_ANT_ARCHIVE}"
APACHE_ANT_HOME="${ANDROID_HOME}/apache-ant"
APACHE_ANT_HOME_V="${APACHE_ANT_HOME}-${APACHE_ANT_VERSION}"


function install_android_pkg ()
{
echo Hello welcome to CIS......................................................................................        # This is a comment, too!
pip install buildozer==$BUILDOZER_VERSION 
pip install --upgrade cython==$CYTHON_VERSION
}


# install system dependencies
function system_dependencies ()
{
	apt -y update -qq
    apt -y install -qq --no-install-recommends python virtualenv python-pip python-setuptools python-wheel git wget unzip lbzip2 patch sudo software-properties-common
    apt -y autoremove

}

# build dependencies
# https://buildozer.readthedocs.io/en/latest/installation.html#android-on-ubuntu-16-04-64bit
function build_dependencies ()
{
    dpkg --add-architecture i386
    apt -y update -qq
    apt -y install -qq --no-install-recommends build-essential ccache git python python-dev libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 zip zlib1g-dev zlib1g:i386
    apt -y autoremove
    apt -y clean
}


# cmake version control 
# function cmake_version_upgrade(){
#     cmake_version=$(cmake --version | grep "cmake version"|cut -d\  -f3)
#     if [ "${cmake_version}" == 3.5.1 ] 
#     then
#         wget -nc https://github.com/Kitware/CMake/releases/download/v3.17.0-rc1/cmake-3.17.0-rc1-Linux-x86_64.tar.gz
#         tar -xvf cmake-3.17.0-rc1-Linux-x86_64.tar.gz
#         cd cmake-3.17.0-rc1-Linux-x86_64
#         sudo cp -r bin /usr/
#         sudo cp -r share /usr/
#         sudo cp -r doc /usr/share/
#         sudo cp -r man /usr/share/

#     fi
# }

function updatescript()
{
    # set -x
    mkdir peternew
    cd peternew
    git clone -b UiChanges https://github.com/surbhicis/PyBitmessage.git
    cd PyBitmessage/src
    sleep 5
    sed -Ei 's/android.api =.*/android.api = 28/;s/android.sdk =.*//;s|#?android.ndk_path =.*|android.ndk_path = /opt/android/android-ndk|;s|#?android.sdk_path =.*|android.sdk_path = /opt/android/android-sdk|;s|#?android.ant_path =.*|android.ant_path = /opt/android/apache-ant|;s|#?p4a.branch =.*|p4a.branch = release-2019.07.08|;s|#?p4a.local_recipes =.*|p4a.local_recipes = bitmessagekivy/android/python-for-android/recipes|' buildozer.spec

}


# specific recipes dependencies (e.g. libffi requires autoreconf binary)
function specific_recipes_dependencies ()
{
	apt -y update -qq
    apt -y install -qq --no-install-recommends libffi-dev autoconf automake cmake gettext libltdl-dev libtool pkg-config
    # cmake_version_upgrade
    apt -y autoremove
    apt -y clean
}


# download and install Android NDK
function install_ndk()
{
	
	echo "Downloading ndk.........................................................................."
	wget -nc ${ANDROID_NDK_DL_URL}
	mkdir --parents "${ANDROID_NDK_HOME_V}" 	
	unzip -q "${ANDROID_NDK_ARCHIVE}" -d "${ANDROID_HOME}" 
	ln -sfn "${ANDROID_NDK_HOME_V}" "${ANDROID_NDK_HOME}" 
	rm -rf "${ANDROID_NDK_ARCHIVE}"
	
}

# download and install Android SDK
function install_sdk()
{
	echo "Downloading sdk.........................................................................."
	wget -nc ${ANDROID_SDK_TOOLS_DL_URL}
    mkdir --parents "${ANDROID_SDK_HOME}"
    unzip -q "${ANDROID_SDK_TOOLS_ARCHIVE}" -d "${ANDROID_SDK_HOME}"
    rm -rf "${ANDROID_SDK_TOOLS_ARCHIVE}"

     # update Android SDK, install Android API, Build Tools...
	mkdir --parents "${ANDROID_SDK_HOME}/.android/" 
    echo '### Sources for Android SDK Manager' > "${ANDROID_SDK_HOME}/.android/repositories.cfg"

    # accept Android licenses (JDK necessary!)
	apt -y update -qq
    apt -y install -qq --no-install-recommends openjdk-8-jdk
    apt -y autoremove
	yes | "${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}" > /dev/null
	
	# download platforms, API, build tools
	"${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "platforms;android-24" > /dev/null
    "${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "platforms;android-28" > /dev/null
    "${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}" > /dev/null
    "${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "extras;android;m2repository" > /dev/null
    chmod 777 -R "${ANDROID_SDK_HOME}"
    chmod +x "${ANDROID_SDK_HOME}/tools/bin/avdmanager"	
}

# download ANT
function install_ant()
{
	
	echo "Downloading ant.........................................................................."
	wget -nc ${APACHE_ANT_DL_URL}
    tar -xf "${APACHE_ANT_ARCHIVE}" -C "${ANDROID_HOME}"
    ln -sfn "${APACHE_ANT_HOME_V}" "${APACHE_ANT_HOME}"
    rm -rf "${APACHE_ANT_ARCHIVE}"
	
}

system_dependencies
build_dependencies
specific_recipes_dependencies
install_android_pkg
install_ndk
install_sdk
install_ant
updatescript

}

# PYTHON-3
function python_3_script()
{

BUILDOZER_VERSION=1.0
CYTHON_VERSION=0.29.15


ANDROID_HOME="/opt/androidnew"
ANDROID_NDK_HOME="${ANDROID_HOME}/android-ndk"
ANDROID_NDK_VERSION=21
ANDROID_NDK_HOME_V=${ANDROID_NDK_HOME}-r${ANDROID_NDK_VERSION}
ANDROID_NDK_ARCHIVE=android-ndk-r${ANDROID_NDK_VERSION}-linux-x86_64.zip
ANDROID_NDK_DL_URL=https://dl.google.com/android/repository/${ANDROID_NDK_ARCHIVE} 


ANDROID_SDK_HOME="${ANDROID_HOME}/android-sdk"
ANDROID_SDK_TOOLS_VERSION="4333796"
ANDROID_SDK_BUILD_TOOLS_VERSION="29.0.2"
ANDROID_SDK_TOOLS_ARCHIVE="sdk-tools-linux-${ANDROID_SDK_TOOLS_VERSION}.zip"
ANDROID_SDK_TOOLS_DL_URL="https://dl.google.com/android/repository/${ANDROID_SDK_TOOLS_ARCHIVE}"


APACHE_ANT_HOME="${ANDROID_HOME}/apache-ant"
APACHE_ANT_VERSION="1.10.7"
APACHE_ANT_ARCHIVE="apache-ant-${APACHE_ANT_VERSION}-bin.tar.gz"
APACHE_ANT_DL_URL="http://archive.apache.org/dist/ant/binaries/${APACHE_ANT_ARCHIVE}"
APACHE_ANT_HOME_V="${APACHE_ANT_HOME}-${APACHE_ANT_VERSION}"


# install android package 
function install_android_pkg ()
{
echo Hello welcome to CIS......................................................................................    
# This is a comment, too!
pip3 install buildozer==$BUILDOZER_VERSION 
pip3 install --upgrade cython==$CYTHON_VERSION

}

# install system dependencies
function system_dependencies ()
{
apt -y update 
apt -y install --no-install-recommends python3-pip pip3 python3 virtualenv python3-setuptools python3-wheel git wget unzip sudo patch bzip2 lzma    
apt -y autoremove
}


# build dependencies
# https://buildozer.readthedocs.io/en/latest/installation.html#android-on-ubuntu-16-04-64bit
function build_dependencies ()
{
dpkg --add-architecture i386
apt -y update -qq
apt -y install -qq --no-install-recommends build-essential ccache git python3 python3-dev libncurses5:i386 libstdc++6:i386 libgtk2.0-0:i386 libpangox-1.0-0:i386 libpangoxft-1.0-0:i386 libidn11:i386 zip zlib1g-dev zlib1g:i386
apt -y autoremove
apt -y clean
}    

# specific recipes dependencies (e.g. libffi requires autoreconf binary)
function specific_recipes_dependencies ()
{
apt -y update -qq
apt -y install -qq --no-install-recommends libffi-dev autoconf automake cmake gettext libltdl-dev libtool pkg-config
apt -y autoremove
apt -y clean
}

# download and install Android NDK
function install_ndk()
{

echo "Downloading ndk.........................................................................."
wget -nc ${ANDROID_NDK_DL_URL}
mkdir --parents "${ANDROID_NDK_HOME_V}" 	
unzip -q "${ANDROID_NDK_ARCHIVE}" -d "${ANDROID_HOME}" 
ln -sfn "${ANDROID_NDK_HOME_V}" "${ANDROID_NDK_HOME}" 
rm -rf "${ANDROID_NDK_ARCHIVE}"

}

# download and install Android SDK
function install_sdk()
{

echo "Downloading sdk.........................................................................."
wget -nc ${ANDROID_SDK_TOOLS_DL_URL}
mkdir --parents "${ANDROID_SDK_HOME}"
unzip -q "${ANDROID_SDK_TOOLS_ARCHIVE}" -d "${ANDROID_SDK_HOME}"
rm -rf "${ANDROID_SDK_TOOLS_ARCHIVE}"
# update Android SDK, install Android API, Build Tools...
mkdir --parents "${ANDROID_SDK_HOME}/.android/"
echo '### Sources for Android SDK Manager' > "${ANDROID_SDK_HOME}/.android/repositories.cfg" 

# accept Android licenses (JDK necessary!) 
apt -y update -qq
# apt -y update-alternatives --config java
apt -y install -qq --no-install-recommends openjdk-8-jdk
apt -y autoremove
yes | "${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}" > /dev/null

# download platforms, API, build tools
"${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "platforms;android-28" > /dev/null						
"${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "build-tools;${ANDROID_SDK_BUILD_TOOLS_VERSION}" > /dev/null
"${ANDROID_SDK_HOME}/tools/bin/sdkmanager" "extras;android;m2repository"  > /dev/null
chmod 777 -R "${ANDROID_SDK_HOME}"
chmod +x "${ANDROID_SDK_HOME}/tools/bin/avdmanager"

}


# download ANT
function install_ant()
{

echo "Downloading ant.........................................................................."
wget -nc ${APACHE_ANT_DL_URL}
tar -xf "${APACHE_ANT_ARCHIVE}" -C "${ANDROID_HOME}"
ln -sfn "${APACHE_ANT_HOME_V}" "${APACHE_ANT_HOME}"
rm -rf "${APACHE_ANT_ARCHIVE}"

}

system_dependencies
build_dependencies
specific_recipes_dependencies
install_android_pkg
install_ndk
install_sdk
install_ant

}


get_python_version=$@ 
if [[ "$get_python_version" -eq " 2 " ]];
then
	python_2_script	
	exit
elif [[ "$get_python_version" -eq " 3 " ]];
then	
	python_3_script
	exit
else	
	echo "please pass a parameter while running a script"	
fi
