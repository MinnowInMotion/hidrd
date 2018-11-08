export LD_LIBRARY_PATH=/data/data/com.claydonkey.hidrdtest/lib
cp /storage/sdcard0/Android/data/com.claydonkey.hidrdtest/files/* /data/data/com.claydonkey.hidrdtest/lib/
mv libhidrd-convert.so hidrd-convert
./hidrd-convert -i hex -o code mouse_descriptor.hex
