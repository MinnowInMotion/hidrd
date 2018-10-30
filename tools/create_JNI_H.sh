!#/bin/sh
#execute both from src

javah -jni -classpath "%ANDROID_SDK_HOME%/platforms/android-21/android.jar";%SRC%\Convolve\hidrd-master\android\bin\classes  com.claydonkey.hidrd.FilePicker
javac  -classpath "%ANDROID_SDK_HOME%/platforms/android-21/android.jar" com\claydonkey\hidrd\FilePicker.java
javah -jni -classpath "%ANDROID_SDK_HOME%/platforms/android-24/android.jar";%SRC%/android/hidrd/hidrd-android/app/build/intermediates/classes/debug com.claydonkey.hidrd.FilePicker