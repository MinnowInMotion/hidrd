!#/bin/sh
#execute both from src

javac -h . -classpath /home/anthony/Android/Sdk/platforms/android-26/android.jar:/home/anthony/Documents/Source/Android/ndk/hidrd/android/hidrdtest/build/intermediates/javac/debug/compileDebugJavaWithJavac/classes  FilePicker.java 

javac  -classpath "%ANDROID_SDK_HOME%/platforms/android-21/android.jar" com\claydonkey\hidrd\FilePicker.java
javah -jni -classpath "%ANDROID_SDK_HOME%/platforms/android-24/android.jar":%SRC%/android/hidrd/hidrd-android/app/build/intermediates/classes/debug com.claydonkey.hidrd.FilePickerj	ls