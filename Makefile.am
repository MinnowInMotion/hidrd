# Copyright (C) 2009-2010 Nikolai Kondrashov
# Additions (C) 2018 Anthony Campbell
# This file is part of hidrd and hidrd-android
#
# Hidrd is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# Hidrd is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with hidrd; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

SUBDIRS = m4 db include lib src

bootstrap:

dist_noinst_SCRIPTS = bootstrap distcheck-all

ACLOCAL_AMFLAGS = -I m4/autoconf

if ENABLE_ADR 

if !ENABLE_CMAKE_WRAPPER	

install-exec-am:

	@echo "Create jniLibs + arch directory and copy libraries"
	$(MKDIR_P) ${srcdir}/android/hidrdinline/src/main/jniLibs/${ARMEABI}
	@echo "Copy Libraries to Android JniLibs Directory"
#NB android only allow .so extensions in jniLibs upload...	
	-$(INSTALL) -m 0644 ${DESTDIR}/${bindir}/hidrd-convert ${srcdir}/android/hidrdinline/src/main/jniLibs/${ARMEABI}/libhidrd-convert.so
	-$(INSTALL) -m 0644 ${DESTDIR}/${libdir}/libhidrd*.so ${srcdir}/android/hidrdinline/src/main/jniLibs/${ARMEABI}

install-data-am:
	@echo "Copy data to android resources directory"
	-$(INSTALL) -m 0644  ${srcdir}/share/mouse_descriptor.code ${srcdir}/android/hidrdinline/src/main/assets
	-$(INSTALL) -m 0644  ${srcdir}/share/mouse_descriptor.hex ${srcdir}/android/hidrdinline/src/main/assets
if WITH_LIBXML2
	-$(INSTALL) -m 0644 ${DESTDIR}/${datadir}/xml/schema/hidrd.xsd ${srcdir}/android/hidrdinline/src/main/assets
	-$(INSTALL) -m 0644  ${srcdir}/share/mouse_descriptor.xml ${srcdir}/android/hidrdinline/src/main/assets

endif

endif

endif
