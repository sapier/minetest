# build options

# how much threads to use for build
PARALLEL = -j4

# compile with GPROF
# GPROF = 1

# build for build platform
APP_PLATFORM = android-9

# paths used for timestaps, dependencys, tree config and libs
PATHCFGFILE = path.cfg

ROOT = $(shell pwd)

################################################################################
# Android Version code
# Increase for each build!
################################################################################
ANDROID_VERSION_CODE = 3

################################################################################
# toolchain config for arm old processors
################################################################################
TARGET_HOST = arm-linux
TARGET_ABI = armeabi
TARGET_LIBDIR = armeabi
TARGET_TOOLCHAIN = arm-linux-androideabi-
CROSS_PREFIX = arm-linux-androideabi-
COMPILER_VERSION = 4.8

################################################################################
# toolchain config for arm new processors
################################################################################
#TARGET_HOST = arm-linux
#TARGET_ABI = armeabi-v7a-hard
#TARGET_LIBDIR = armeabi-v7a
#TARGET_TOOLCHAIN = arm-linux-androideabi-
#TARGET_CFLAGS_ADDON =  -mfpu=vfp -mfloat-abi=hard -D_NDK_MATH_NO_SOFTFP=1 \
						-mfloat-abi=hard -march=armv7-a
#TARGET_CXXFLAGS_ADDON = $(TARGET_CFLAGS_ADDON)
#TARGET_LDFLAGS_ADDON = -Wl,--no-warn-mismatch -lm_hard
#CROSS_PREFIX = arm-linux-androideabi-
#COMPILER_VERSION = 4.8

################################################################################
# toolchain config for little endian mips
################################################################################
#TARGET_HOST = mipsel-linux
#TARGET_ABI = mips
#TARGET_LIBDIR = mips
#TARGET_TOOLCHAIN = mipsel-linux-android-
#CROSS_PREFIX = mipsel-linux-android-
#COMPILER_VERSION = 4.8

################################################################################
# toolchain config for x86
################################################################################
#TARGET_HOST = x86-linux
#TARGET_ABI = x86
#TARGET_LIBDIR = x86
#TARGET_TOOLCHAIN = x86-
#CROSS_PREFIX = i686-linux-android-
#COMPILER_VERSION = 4.8

################################################################################
ASSETS_TIMESTAMP = deps/assets_timestamp

LEVELDB_DIR = $(ROOT)/deps/leveldb/
LEVELDB_LIB = $(LEVELDB_DIR)libleveldb.a
LEVELDB_TIMESTAMP = $(LEVELDB_DIR)/timestamp
LEVELDB_TIMESTAMP_INT = $(ROOT)/deps/leveldb_timestamp

OPENAL_DIR = $(ROOT)/deps/openal-soft/
OPENAL_LIB = $(OPENAL_DIR)libs/$(TARGET_ABI)/libopenal.so
OPENAL_TIMESTAMP = $(OPENAL_DIR)/timestamp
OPENAL_TIMESTAMP_INT = $(ROOT)/deps/openal_timestamp

OGG_DIR = $(ROOT)/deps/libvorbis-libogg-android/
OGG_LIB = $(OGG_DIR)libs/$(TARGET_ABI)/libogg.so
VORBIS_LIB = $(OGG_DIR)libs/$(TARGET_ABI)/libogg.so
OGG_TIMESTAMP = $(OGG_DIR)timestamp
OGG_TIMESTAMP_INT = $(ROOT)/deps/ogg_timestamp

IRRLICHT_DIR = $(ROOT)/deps/irrlicht/
IRRLICHT_LIB = $(IRRLICHT_DIR)lib/Android/libIrrlicht.a
IRRLICHT_TIMESTAMP = $(IRRLICHT_DIR)timestamp
IRRLICHT_TIMESTAMP_INT = $(ROOT)/deps/irrlicht_timestamp

OPENSSL_REPO = https://github.com/wobbals/openssl-android
OPENSSL_BASEDIR = openssl-android
OPENSSL_DIR = $(ROOT)/deps/$(OPENSSL_BASEDIR)/
OPENSSL_LIB = $(OPENSSL_DIR)libs/$(TARGET_ABI)/libopenssl.so
OPENSSL_TIMESTAMP = $(OPENSSL_DIR)timestamp
OPENSSL_TIMESTAMP_INT = $(ROOT)/deps/openssl_timestamp

CURL_VERSION = 7.35.0
CURL_DIR = $(ROOT)/deps/curl-$(CURL_VERSION)
CURL_LIB = $(CURL_DIR)/lib/.libs/libcurl.a
CURL_TIMESTAMP = $(CURL_DIR)/timestamp
CURL_TIMESTAMP_INT = $(ROOT)/deps/curl_timestamp

FREETYPE_DIR = $(ROOT)/deps/freetype2-android/
FREETYPE_LIB = $(FREETYPE_DIR)/Android/obj/local/$(TARGER_ABI)/libfreetype2-static.a
FREETYPE_TIMESTAMP = $(FREETYPE_DIR)timestamp
FREETYPE_TIMESTAMP_INT = $(ROOT)/deps/freetype_timestamp


OGLES2_SHADER_PATH=\"/sdcard/Minetest/media/Shaders/\"

-include $(PATHCFGFILE)

.PHONY : debug release reconfig delconfig \
	leveldb_download clean_leveldb leveldb\
	irrlicht_download clean_irrlicht irrlicht \
	clean_assets assets \
	freetype_download clean_freetype freetype \
	apk_debug apk_release clean_apk \
	clean_all clean prep_srcdir \
	install_debug install envpaths all \
	manifest \
	$(ASSETS_TIMESTAMP) $(LEVELDB_TIMESTAMP) \
	$(OPENAL_TIMESTAMP) $(OGG_TIMESTAMP) \
	$(IRRLICHT_TIMESTAMP) $(CURL_TIMESTAMP) \
	$(OPENSSL_TIMESTAMP) curl_binary \
	$(ROOT)/jni/src/android_version.h

debug : $(PATHCFGFILE) 
	make apk_debug
	
all : debug release
	
release : $(PATHCFGFILE)
	make apk_release

reconfig: delconfig
	make $(PATHCFGFILE)

delconfig :
	$(RM) ${PATHCFGFILE}

$(PATHCFGFILE) :
	@echo "Please specify path of ANDROID NDK";                                \
	echo "e.g. /home/user/android-ndk-r9c/";                                   \
	read ANDROID_NDK ;                                                         \
	if [ ! -d $$ANDROID_NDK ] ; then                                           \
		echo "$$ANDROID_NDK is not a valid folder";                            \
		exit 1;                                                                \
	fi;                                                                        \
	echo "ANDROID_NDK = $$ANDROID_NDK" > ${PATHCFGFILE};                       \
	echo "NDK_MODULE_PATH = $$ANDROID_NDK/tools" >> ${PATHCFGFILE};            \
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";\
	echo "+ Note: NDK_MODULE_PATH is set to $$ANDROID_NDK/tools";              \
	echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++";\
	echo "Please specify path of ANDROID SDK";                                 \
	echo "e.g. /home/user/adt-bundle-linux-x86_64-20131030/sdk/";              \
	read SDKFLDR ;                                                             \
	if [ ! -d $$SDKFLDR ] ; then                                               \
		echo "$$SDKFLDR is not a valid folder";                                \
		exit 1;                                                                \
	fi;                                                                        \
	echo "SDKFOLDER = $$SDKFLDR" >> ${PATHCFGFILE};

$(OPENAL_TIMESTAMP) : openal_download
	@LAST_MODIF=$$(find ${OPENAL_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${OPENAL_TIMESTAMP};                                            \
	fi
	
openal_download :
	@if [ ! -d ${OPENAL_DIR} ] ; then                                          \
		echo "openal sources missing, downloading...";                         \
		mkdir -p ${ROOT}/deps;                                                 \
		cd ${ROOT}/deps ;                                                      \
		git clone https://github.com/apportable/openal-soft || exit 1;         \
	fi
	
openal : $(OPENAL_LIB)

$(OPENAL_LIB): $(OPENAL_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${OPENAL_TIMESTAMP_INT} ] ; then                                 \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${OPENAL_TIMESTAMP} -nt ${OPENAL_TIMESTAMP_INT} ] ; then              \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};             \
	echo "changed timestamp for openal detected building...";                  \
	cd ${OPENAL_DIR};                                                          \
	ndk-build NDEBUG=${NDEBUG} NDK_MODULE_PATH=${NDK_MODULE_PATH} ${PARALLEL}  \
	APP_ABI=${TARGET_ABI} APP_PLATFORM=${APP_PLATFORM}                         \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" || exit 1;                     \
	touch ${OPENAL_TIMESTAMP};                                                 \
	touch ${OPENAL_TIMESTAMP_INT};                                             \
	else                                                                       \
		echo "nothing to be done for openal";                                  \
	fi
	
clean_openal :
	$(RM) -rf ${OPENAL_DIR}
	
$(OGG_TIMESTAMP) : ogg_download
	@LAST_MODIF=$$(find ${OGG_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${OGG_TIMESTAMP};                                                \
	fi
	
ogg_download :
	@if [ ! -d ${OGG_DIR} ] ; then                                             \
		echo "ogg sources missing, downloading...";                            \
		mkdir -p ${ROOT}/deps;                                                 \
		cd ${ROOT}/deps ;                                                      \
		git clone https://github.com/vincentjames501/libvorbis-libogg-android|| exit 1;\
	fi
	
ogg : $(OGG_LIB)

$(OGG_LIB): $(OGG_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${OGG_TIMESTAMP_INT} ] ; then                                    \
		echo "${OGG_TIMESTAMP_INT} doesn't exist";                             \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${OGG_TIMESTAMP} -nt ${OGG_TIMESTAMP_INT} ] ; then                    \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};             \
	echo "changed timestamp for ogg detected building...";                     \
	cd ${OGG_DIR};                                                             \
	ndk-build NDEBUG=${NDEBUG} NDK_MODULE_PATH=${NDK_MODULE_PATH} ${PARALLEL}  \
	APP_ABI=${TARGET_ABI} APP_PLATFORM=${APP_PLATFORM}                         \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" || exit 1;                     \
	touch ${OGG_TIMESTAMP};                                                    \
	touch ${OGG_TIMESTAMP_INT};                                                \
	else                                                                       \
		echo "nothing to be done for libogg/libvorbis";                        \
	fi

clean_ogg :
	$(RM) -rf ${OGG_DIR}
	
$(OPENSSL_TIMESTAMP) : openssl_download
	@LAST_MODIF=$$(find ${OPENSSL_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${OPENSSL_TIMESTAMP};                                            \
	fi
	
openssl_download :
	@if [ ! -d ${OPENSSL_DIR} ] ; then                                         \
		echo "openssl sources missing, downloading...";                        \
		mkdir -p ${ROOT}/deps;                                                 \
		cd ${ROOT}/deps ;                                                      \
		git clone ${OPENSSL_REPO} || exit 1;                                   \
	fi
	
openssl : $(OPENSSL_LIB)

$(OPENSSL_LIB): $(OPENSSL_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${OPENSSL_TIMESTAMP_INT} ] ; then                                \
		echo "${OPENSSL_TIMESTAMP_INT} doesn't exist";                         \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${OPENSSL_TIMESTAMP} -nt ${OPENSSL_TIMESTAMP_INT} ] ; then            \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};             \
	echo "changed timestamp for openssl detected building...";                 \
	cd ${OPENSSL_DIR};                                                         \
	cat jni/Application.mk | grep -v NDK_TOOLCHAIN_VERSION >jni/Application.mk.new;\
	mv jni/Application.mk.new jni/Application.mk;                              \
	ndk-build NDEBUG=${NDEBUG} NDK_MODULE_PATH=${NDK_MODULE_PATH} ${PARALLEL}  \
	APP_ABI=${TARGET_ABI} APP_PLATFORM=${APP_PLATFORM}                         \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" || exit 1;                     \
	touch ${OPENSSL_TIMESTAMP};                                                \
	touch ${OPENSSL_TIMESTAMP_INT};                                            \
	else                                                                       \
		echo "nothing to be done for openssl";                        \
	fi

clean_openssl :
	$(RM) -rf ${OPENSSL_DIR}

$(LEVELDB_TIMESTAMP) : leveldb_download
	@LAST_MODIF=$$(find ${LEVELDB_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${LEVELDB_TIMESTAMP};                                            \
	fi

leveldb_download :
	@if [ ! -d ${LEVELDB_DIR} ] ; then                                         \
		echo "leveldb sources missing, downloading...";                        \
		mkdir -p ${ROOT}/deps;                                                 \
		cd ${ROOT}/deps ;                                                      \
		git clone https://code.google.com/p/leveldb/ || exit 1;                \
	fi
	
leveldb : $(LEVELDB_LIB)

$(LEVELDB_LIB): $(LEVELDB_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${LEVELDB_TIMESTAMP_INT} ] ; then                                \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${LEVELDB_TIMESTAMP} -nt ${LEVELDB_TIMESTAMP_INT} ] ; then            \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	export PATH=$${PATH}:${SDKFOLDER}/platform-tools:${ANDROID_NDK};           \
	echo "changed timestamp for leveldb detected building...";                 \
	cd deps/leveldb;                                                           \
	export CROSS_PREFIX=${CROSS_PREFIX};                                       \
	export TOOLCHAIN=/tmp/ndk-arm;                                             \
	${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh                    \
	--toolchain=${TARGET_TOOLCHAIN}${COMPILER_VERSION}                         \
	--install-dir=$${TOOLCHAIN} --system=linux-x86_64;                         \
	export PATH="$${TOOLCHAIN}/bin:$${PATH}";                                  \
	export CC=${CROSS_PREFIX}gcc;                                              \
	export CXX=${CROSS_PREFIX}g++;                                             \
	export CFLAGS="$${CFLAGS} ${TARGET_CFLAGS_ADDON}";                         \
	export CPPFLAGS="$${CPPFLAGS} ${TARGET_CFLAGS_ADDON}";                     \
	export LDFLAGS="$${LDFLAGS} ${TARGET_LDFLAGS_ADDON}";                      \
	export TARGET_OS=OS_ANDROID_CROSSCOMPILE;                                  \
	make -s ${PARALLEL} || exit 1;                                             \
	touch ${LEVELDB_TIMESTAMP};                                                \
	touch ${LEVELDB_TIMESTAMP_INT};                                            \
	else                                                                       \
		echo "nothing to be done for leveldb";                                 \
	fi
	
clean_leveldb :
	$(RM) -rf deps/leveldb
	
$(FREETYPE_TIMESTAMP) : freetype_download
	@LAST_MODIF=$$(find ${FREETYPE_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${FREETYPE_TIMESTAMP};                                           \
	fi

freetype_download :
	@if [ ! -d ${FREETYPE_DIR} ] ; then                                        \
		echo "freetype sources missing, downloading...";                       \
		mkdir -p ${ROOT}/deps;                                                 \
		cd deps;                                                               \
		git clone https://github.com/cdave1/freetype2-android || exit 1;       \
	fi
	
$(IRRLICHT_TIMESTAMP) : irrlicht_download
	@LAST_MODIF=$$(find ${IRRLICHT_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${IRRLICHT_TIMESTAMP};                                           \
	fi
	
freetype : $(FREETYPE_LIB)

$(FREETYPE_LIB) : $(FREETYPE_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${FREETYPE_TIMESTAMP_INT} ] ; then                               \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ! -e ${FREETYPE_LIB} ] ; then                                         \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${FREETYPE_TIMESTAMP} -nt ${FREETYPE_TIMESTAMP_INT} ] ; then          \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	mkdir -p ${FREETYPE_DIR};                                                  \
	export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};             \
	echo "changed timestamp for freetype detected building...";                \
	cd ${FREETYPE_DIR}/Android/jni;                                            \
	ndk-build NDEBUG=${NDEBUG} NDK_MODULE_PATH=${NDK_MODULE_PATH} ${PARALLEL}  \
	APP_PLATFORM=${APP_PLATFORM} APP_ABI=${TARGET_ABI}                         \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" || exit 1;                     \
	touch ${FREETYPE_TIMESTAMP};                                               \
	touch ${FREETYPE_TIMESTAMP_INT};                                           \
	else                                                                       \
		echo "nothing to be done for freetype";                                \
	fi
	
clean_freetype :
	$(RM) -rf ${FREETYPE_DIR}

irrlicht_download :
	@if [ ! -d "deps/irrlicht" ] ; then                                        \
		echo "irrlicht sources missing, downloading...";                       \
		mkdir -p ${ROOT}/deps;                                                 \
		cd deps;                                                               \
		svn co http://svn.code.sf.net/p/irrlicht/code/branches/ogl-es/ irrlicht || exit 1;\
		cd irrlicht;                                                           \
		patch -p1 < ../../irrlicht-touchcount.patch || exit 1;                 \
		patch -p1 < ../../irrlicht-back_button.patch || exit 1;                \
	fi

irrlicht : $(IRRLICHT_LIB)

$(IRRLICHT_LIB): $(IRRLICHT_TIMESTAMP) $(FREETYPE_LIB)
	@REFRESH=0;                                                                \
	if [ ! -e ${IRRLICHT_TIMESTAMP_INT} ] ; then                               \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ! -e ${IRRLICHT_LIB} ] ; then                                         \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${IRRLICHT_TIMESTAMP} -nt ${IRRLICHT_TIMESTAMP_INT} ] ; then          \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	mkdir -p ${IRRLICHT_DIR};                                                  \
	export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};             \
	echo "changed timestamp for irrlicht detected building...";                \
	cd deps/irrlicht/source/Irrlicht/Android;                                  \
	ndk-build NDEBUG=${NDEBUG} NDK_MODULE_PATH=${NDK_MODULE_PATH} ${PARALLEL}  \
	IRR_OGLES2_SHADER_PATH=${OGLES2_SHADER_PATH}                               \
	APP_ABI=${TARGET_ABI} APP_PLATFORM=${APP_PLATFORM}                         \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" || exit 1;                     \
	touch ${IRRLICHT_TIMESTAMP};                                               \
	touch ${IRRLICHT_TIMESTAMP_INT};                                           \
	else                                                                       \
		echo "nothing to be done for irrlicht";                                \
	fi
	
clean_irrlicht :
	$(RM) -rf deps/irrlicht
	
$(CURL_TIMESTAMP) : curl_download
	@LAST_MODIF=$$(find ${CURL_DIR} -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${CURL_TIMESTAMP};                                               \
	fi

curl_download :
	@if [ ! -d "deps/curl-${CURL_VERSION}" ] ; then                            \
		echo "curl sources missing, downloading...";                           \
		mkdir -p ${ROOT}/deps;                                                 \
		cd deps;                                                               \
		wget http://curl.haxx.se/download/curl-${CURL_VERSION}.tar.bz2 || exit 1;\
		tar -xjf curl-${CURL_VERSION}.tar.bz2 || exit 1;                       \
		rm curl-${CURL_VERSION}.tar.bz2;                                       \
	fi

curl : $(CURL_LIB)

$(CURL_LIB): $(CURL_TIMESTAMP) $(OPENSSL_LIB)
	@REFRESH=0;                                                                \
	if [ ! -e ${CURL_TIMESTAMP_INT} ] ; then                                   \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ! -e ${CURL_LIB} ] ; then                                             \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${CURL_TIMESTAMP} -nt ${CURL_TIMESTAMP_INT} ] ; then                  \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	mkdir -p ${CURL_DIR};                                                      \
	export PATH="$${PATH}:${SDKFOLDER}/platform-tools:${ANDROID_NDK}";         \
	echo "changed timestamp for curl detected building...";                    \
	cd deps/curl-${CURL_VERSION};                                              \
	export CROSS_PREFIX=${CROSS_PREFIX};                                       \
	export TOOLCHAIN=/tmp/ndk-arm;                                             \
	${ANDROID_NDK}/build/tools/make-standalone-toolchain.sh                    \
	--toolchain=${TARGET_TOOLCHAIN}${COMPILER_VERSION}                         \
	--install-dir=$${TOOLCHAIN} --system=linux-x86_64;                         \
	export PATH="$${TOOLCHAIN}/bin:$${PATH}";                                  \
	export CC=${CROSS_PREFIX}gcc;                                              \
	export CXX=${CROSS_PREFIX}g++;                                             \
	export TARGET_OS=OS_ANDROID_CROSSCOMPILE;                                  \
	export CPPFLAGS="$${CPPFLAGS} -I${OPENSSL_DIR}/include                     \
	-L${OPENSSL_DIR}/libs/${TARGET_ABI}/ ${TARGET_CFLAGS_ADDON}";              \
	export CFLAGS="$${CFLAGS} ${TARGET_CFLAGS_ADDON}";                         \
	export LDFLAGS="$${LDFLAGS} -L${OPENSSL_DIR}/libs/${TARGET_ABI}/           \
	${TARGET_LDFLAGS_ADDON}";                                                  \
	./configure --host=${TARGET_HOST} --disable-shared --enable-static --with-ssl;  \
	make -s ${PARALLEL} || exit 1;                                             \
	touch ${CURL_TIMESTAMP};                                                   \
	touch ${CURL_TIMESTAMP_INT};                                               \
	else                                                                       \
		echo "nothing to be done for curl";                                    \
	fi
	
clean_curl :
	$(RM) -rf deps/curl-${CURL_VERSION}
	
	
curl_binary: 
	@if [ ! -d "deps/curl-${CURL_VERSION_BINARY}" ] ; then                     \
		echo "curl sources missing, downloading...";                           \
		mkdir -p ${ROOT}/deps;                                                 \
		cd deps;                                                               \
		wget http://curl.haxx.se/gknw.net/7.34.0/dist-android/curl-7.34.0-rtmp-ssh2-ssl-zlib-static-bin-android.tar.gz || exit 1;\
		tar -xzf curl-7.34.0-rtmp-ssh2-ssl-zlib-static-bin-android.tar.gz || exit 1;\
		mv curl-7.34.0-rtmp-ssh2-ssl-zlib-static-bin-android curl-${CURL_VERSION_BINARY};\
		rm curl-7.34.0-rtmp-ssh2-ssl-zlib-static-bin-android.tar.gz;           \
	fi

$(ASSETS_TIMESTAMP) : $(IRRLICHT_LIB)
	@mkdir -p ${ROOT}/deps;                                                     \
	LAST_MODIF=$$(find ${ROOT}/../../builtin -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../builtin/timestamp;                                 \
		touch ${ASSETS_TIMESTAMP};                                             \
		echo builtin changed $$LAST_MODIF;                                     \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../client -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../client/timestamp;                                  \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../doc -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../doc/timestamp;                                     \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../fonts -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../fonts/timestamp;                                   \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../games -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../games/timestamp;                                   \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../mods -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../mods/timestamp;                                    \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../po -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../po/timestamp;                                      \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${ROOT}/../../textures -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${ROOT}/../../textures/timestamp;                                \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	LAST_MODIF=$$(find ${IRRLICHT_DIR}/media -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -f2- -d" "); \
	if [ $$(basename $$LAST_MODIF) != "timestamp" ] ; then                     \
		touch ${IRRLICHT_DIR}/media/timestamp;                                 \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	if [ ${ROOT}/../../minetest.conf.example -nt ${ASSETS_TIMESTAMP} ] ; then  \
		echo "conf changed";                                                   \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	if [ ${ROOT}/../../README.txt -nt ${ASSETS_TIMESTAMP} ] ; then             \
		touch ${ASSETS_TIMESTAMP};                                             \
	fi;                                                                        \
	if [ ! -e $(ASSETS_TIMESTAMP) ] ; then                                     \
		touch $(ASSETS_TIMESTAMP);                                             \
	fi
	
assets : $(ASSETS_TIMESTAMP)
	@REFRESH=0;                                                                \
	if [ ! -e ${ASSETS_TIMESTAMP}.old ] ; then                                 \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ${ASSETS_TIMESTAMP} -nt ${ASSETS_TIMESTAMP}.old ] ; then              \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ ! -d ${ROOT}/assets ] ; then                                          \
		REFRESH=1;                                                             \
	fi;                                                                        \
	if [ $$REFRESH -ne 0 ] ; then                                              \
	echo "assets changed, refreshing...";                                      \
	make clean_assets;                                                         \
	mkdir -p ${ROOT}/assets/Minetest;                                          \
	cp ${ROOT}/../../minetest.conf.example ${ROOT}/assets/Minetest;            \
	cp ${ROOT}/../../README.txt ${ROOT}/assets/Minetest;                       \
	cp -r ${ROOT}/../../builtin ${ROOT}/assets/Minetest;                       \
	cp -r ${ROOT}/../../client ${ROOT}/assets/Minetest;                        \
	cp -r ${ROOT}/../../doc ${ROOT}/assets/Minetest;                           \
	cp -r ${ROOT}/../../fonts ${ROOT}/assets/Minetest;                         \
	cp -r ${ROOT}/../../games ${ROOT}/assets/Minetest;                         \
	cp -r ${ROOT}/../../mods ${ROOT}/assets/Minetest;                          \
	cp -r ${ROOT}/../../po ${ROOT}/assets/Minetest;                            \
	cp -r ${ROOT}/../../textures ${ROOT}/assets/Minetest;                      \
	mkdir -p ${ROOT}/assets/Minetest/media;                                    \
	cp -r ${IRRLICHT_DIR}/media/Shaders ${ROOT}/assets/Minetest/media;         \
	cd ${ROOT}/assets;                                                         \
	touch Minetest/.nomedia;                                                   \
	find . -name "timestamp" -exec rm {} \; ;                                  \
	find . -name "*.blend" -exec rm {} \; ;                                    \
	ls -R | grep ":$$" | sed -e 's/:$$//' -e 's/\.//' -e 's/^\///' > "index.txt"; \
	cp ${ROOT}/${ASSETS_TIMESTAMP} ${ROOT}/${ASSETS_TIMESTAMP}.old;            \
	else                                                                       \
		echo "nothing to be done for assets";                                  \
	fi

clean_assets :
	@$(RM) -r assets
	
apk_debug: $(PATHCFGFILE) assets $(IRRLICHT_LIB) $(CURL_LIB) manifest          \
	$(OPENAL_LIB) $(OGG_LIB) prep_srcdir $(ROOT)/jni/src/android_version.h
	@export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};            \
	export ANDROID_HOME=${SDKFOLDER};                                          \
	mkdir -p ${ROOT}/src;                                                      \
	ndk-build NDK_MODULE_PATH=${NDK_MODULE_PATH}                               \
	NDEBUG=${NDEBUG} GPROF=${GPROF} APP_ABI=${TARGET_ABI} ${PARALLEL}          \
	APP_PLATFORM=${APP_PLATFORM}                                               \
	TARGET_LIBDIR=${TARGET_LIBDIR}                                             \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" &&                             \
	ant debug &&                                                               \
	echo "++ Success!" &&                                                      \
	echo "APK: bin/Minetest-debug.apk" &&                                      \
	echo "You can install it with \`adb install -r bin/Minetest-debug.apk\`"

apk_release: $(PATHCFGFILE) assets $(IRRLICHT_LIB) $(CURL_LIB) manifest        \
	$(OPENAL_LIB) $(OGG_LIB) prep_srcdir $(ROOT)/jni/src/android_version.h
	@export PATH=$$PATH:${SDKFOLDER}/platform-tools:${ANDROID_NDK};            \
	export ANDROID_HOME=${SDKFOLDER};                                          \
	mkdir -p ${ROOT}/src;                                                      \
	ndk-build NDK_MODULE_PATH=${NDK_MODULE_PATH}                               \
	NDEBUG= GPROF= APP_ABI=${TARGET_ABI} ${PARALLEL}                           \
	APP_PLATFORM=${APP_PLATFORM}                                               \
	TARGET_LIBDIR=${TARGET_LIBDIR}                                             \
	TARGET_CFLAGS+="${TARGET_CFLAGS_ADDON}"                                    \
	TARGET_LDFLAGS+="${TARGET_LDFLAGS_ADDON}"                                  \
	TARGET_CXXFLAGS+="${TARGET_CXXFLAGS_ADDON}" &&                             \
	ant release &&                                                             \
	echo "++ Success!" &&                                                      \
	echo "APK: bin/Minetest.apk" &&                                            \
	echo "You can install it with \`adb install -r bin/Minetest.apk\`"
	
prep_srcdir :
	@rm ${ROOT}/jni/src;                                                       \
	ln -s ${ROOT}/../../src ${ROOT}/jni/src
	
clean_apk :
	@export PATH=$$PATH:${SDKFOLDER}platform-tools:${ANDROID_NDK};             \
	export ANDROID_HOME=${SDKFOLDER};                                          \
	ndk-build clean;                                                           \
	ant clean
	
install_debug : 
	@export PATH=$$PATH:${SDKFOLDER}platform-tools:${ANDROID_NDK};             \
	adb install -r ${ROOT}/bin/Minetest-debug.apk
	
install :
	@export PATH=$$PATH:${SDKFOLDER}platform-tools:${ANDROID_NDK};             \
	adb install -r ${ROOT}/bin/Minetest-release.apk
	
envpaths :
	@echo "export PATH=$$PATH:${SDKFOLDER}platform-tools:${ANDROID_NDK}" > and_env;\
	echo "export ANDROID_HOME=${SDKFOLDER}" >> and_env;
	
clean_all : 
	make clean_apk;                                                            \
	make clean_assets clean_irrlicht clean_leveldb clean_curl clean_openssl    \
	clean_openal clean_ogg;                                                    \
	sleep 1;                                                                   \
	$(RM) -r gen libs obj deps bin Debug and_env
	
$(ROOT)/jni/src/android_version.h :
	@echo "#define STR_HELPER(x) #x"                                           \
	>${ROOT}/jni/src/android_version.h;                                        \
	echo "#define STR(x) STR_HELPER(x)"                                        \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define VERSION_MAJOR $$(cat ${ROOT}/../../CMakeLists.txt |          \
	grep ^set\(VERSION_MAJOR\ | sed 's/)/ /' | awk '{print $$2;}')"            \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define VERSION_MINOR $$(cat ${ROOT}/../../CMakeLists.txt |          \
	grep ^set\(VERSION_MINOR\ | sed 's/)/ /' | awk '{print $$2;}')"            \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define VERSION_PATCH $$(cat ${ROOT}/../../CMakeLists.txt |          \
	grep ^set\(VERSION_PATCH\ | sed 's/)/ /' | awk '{print $$2;}')"            \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define VERSION_PATCH_ORIG $$(cat ${ROOT}/../../CMakeLists.txt |     \
	grep ^set\(VERSION_PATCH\ | sed 's/)/ /' | awk '{print $$2;}')"            \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define CMAKE_VERSION_GITHASH \"$$(git rev-parse --short=8 HEAD)\""  \
	>> ${ROOT}/jni/src/android_version.h;                                      \
	echo "#define CMAKE_VERSION_STRING STR(VERSION_MAJOR)\".\"STR(VERSION_MINOR)\
	\".\"STR(VERSION_PATCH)"                                                   \
	>> ${ROOT}/jni/src/android_version.h;
	
manifest :
	@VERS_MAJOR=$$(cat ${ROOT}/../../CMakeLists.txt |                          \
	grep ^set\(VERSION_MAJOR\ | sed 's/)/ /' | awk '{print $$2;}');            \
	VERS_MINOR=$$(cat ${ROOT}/../../CMakeLists.txt |                           \
	grep ^set\(VERSION_MINOR\ | sed 's/)/ /' | awk '{print $$2;}');            \
	VERS_PATCH=$$(cat ${ROOT}/../../CMakeLists.txt |                           \
	grep ^set\(VERSION_PATCH\ | sed 's/)/ /' | awk '{print $$2;}');            \
	BASE_VERSION="$$VERS_MAJOR.$$VERS_MINOR.$$VERS_PATCH";                     \
	if [ "${NDEBUG}x" = "x" ] ; then                                           \
		DBG="<uses-permission android:name=\"android.permission.SET_DEBUG_APP\" />"; \
	else                                                                       \
		DBG='';                                                                \
	fi;                                                                        \
	cat ${ROOT}/AndroidManifest.xml.template |                                 \
	sed s/###ANDROID_VERSION###/${ANDROID_VERSION_CODE}/g |                    \
	sed s/###BASE_VERSION###/$$BASE_VERSION/g |                                \
	sed -e "s@###DEBUG_BUILD###@$$DBG@g" >${ROOT}/AndroidManifest.xml

clean : clean_apk clean_assets
