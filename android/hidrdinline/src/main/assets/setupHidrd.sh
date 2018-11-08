export LD_LIBRARY_PATH=/data/data/com.claydonkey.hidrd/lib
cp /storage/sdcard0/Android/data/com.claydonkey.hidrd/files/* /data/data/com.claydonkey.hidrd/lib/
mv libhidrd-convert.so hidrd-convert
./hidrd-convert -i hex -o code mouse_descriptor.hex