#!/bin/sh

SDIR=$(dirname $0)
cp $SDIR/../lib/adr/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/fmt/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/strm/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/opt/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/item/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/usage/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../lib/util/.libs/*.so $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a
cp $SDIR/../src/.libs/hidrd-convert $SDIR/../hidrd-android/app/src/main/jniLibs/arm64-v8a/libhidrd-convert.so
