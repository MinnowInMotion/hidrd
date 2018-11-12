#
# Copyright (C) 2009-2010 Nikolai Kondrashov
#
# This file is part of hidrd.
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
#
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.68)
AC_INIT([hidrd], [0.2])
AC_CONFIG_AUX_DIR([auxdir])
AM_INIT_AUTOMAKE([1.14 -Wall foreign -Wno-portability])
AC_CONFIG_HEADER([config.h])
AC_CONFIG_MACRO_DIR([m4/autoconf])

m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

CFLAGS=$CFLAGS
# To have empty CFLAGS instead of undefined and '-g -O2' by default

build_os=`uname -s`
target_os=$target

AC_MSG_RESULT([checking build system: ${build_os}])

AM_CONDITIONAL([TARGET_OS], [test "x$target_os"  != ""])


AC_SEARCH_LIBS([dlopen], [dl dld], [], [
  AC_MSG_ERROR([unable to find the dlopen() function])
])


AC_CHECK_HEADERS([obstack.h], [found_obstack_headers=yes; break;])
AM_CONDITIONAL(ADD_OBSTACK, [test x$found_obstack_headers != xyes])

#AM_CONDITIONAL([MINGW_FIX], [test "x$target_os" = xmingw])
#AM_COND_IF([MINGW_FIX],
#[AC_MSG_RESULT([configure: MinGW Strings])
#AC_DEFINE(snprintf, __mingw_printf , mingw uses its own snprintf function)
#AC_DEFINE( __USE_MINGW_ANSI_STDIO , 0 , disablevsnprintf in various headers)
#])

AC_HEADER_STDC


AC_MSG_CHECKING(whether program_invocation_short_name is defined)
AC_TRY_COMPILE([#include <argp.h>],
               [program_invocation_short_name = "test";],
               AC_DEFINE(HAVE_PROGRAM_INVOCATION_SHORT_NAME, 1,
                [Define if program_invocation_short_name is defined])
                AC_MSG_RESULT(yes),
               AC_MSG_RESULT(no))


ABS_SRCDIR=`cd ${srcdir} ; pwd`
ABS_BUILDDIR=`pwd`
CPPFLAGS="-I${ABS_BUILDDIR} -I${ABS_BUILDDIR}/include -D_GNU_SOURCE -DNDEBUG $CPPFLAGS"
if test "$ABS_SRCDIR" != "$ABS_BUILDDIR"; then
    CPPFLAGS="-I${ABS_SRCDIR}/include $CPPFLAGS"
fi

AH_BOTTOM([
/* Temporary fix to allow Mingw32 to compile
*   @author Anthony Campbell <contact@claydonkey.com>
*   Android is Assumed to be Cross compilation and as such will not test for bcopy locally
*/
#if  !defined(HAVE_BCOPY)
    #if defined(HAVE_ANDROID)
      #define bcopy(b1, b2, len) (void)(__builtin_memmove((b2), (b1), (len)))
    #else
      #define bcopy(b1, b2, len) memcpy(b2, b1, len)
    #endif
#endif
 #if !defined(HAVE_ANDROID)
    #if  !defined(HAVE_ASPRINTF)
        #define asprintf(strp,fmt,...) sprintf(*strp,fmt,__VA_ARGS__)
    #endif
    #if  !defined(HAVE_VASPRINTF)
        #define vasprintf(strp,fmt,va_list ) vsprintf(*strp,fmt,va_list )
    #endif
#endif

])
#
# Checks for programs.
#
AC_PROG_CC
AC_PROG_INSTALL
AC_PROG_MKDIR_P

m4_ifdef([AM_PROG_AR], [AM_PROG_AR])


LT_INIT(shared static [win32-dll])
AM_COND_IF([TARGET_OS],,  [case "$build_os" in  MINGW* | MSYS* | cygwin* | msys* | mingw* | cegcc*) target_os=mingw ;;  esac])

case "$target_os" in
    MINGW* | cygwin* | msys* | mingw* | cegcc*)
        CFLAGS="-Wno-format  -Wall -Wextra  -DHAVE_CONFIG_H -static  $CFLAGS"
        LDFLAGS="$LDFLAGS -Wl,--no-undefined"
       AC_MSG_RESULT([configure: Flags for MINGW MSYS CYGWIN])
    ;;
    *android* | *ANDROID*)
        CFLAGS="-fPIE -fPIC -Wall -Wextra -DHAVE_CONFIG_H $CFLAGS"
        LDFLAGS="$LDFLAGS -pie -llog"
       AC_MSG_RESULT([configure: Flags for android])
    ;;
        *)
        CFLAGS="-Wall -Wextra -Werror -DHAVE_CONFIG_H $CFLAGS"
       AC_MSG_RESULT([configure: Flags for linux])
    ;;
esac

xml2_config_bin=""

if test "${with_sysroot+set}" = set; then
    AC_MSG_RESULT([configure: sysroot exists at ${with_sysroot}])
  xml2_config_bin="${with_sysroot}/usr/bin/"
 fi

AC_MSG_RESULT([target os: ${target_os}])

#
# Checks for libraries.
#

XML2_CONFIG=
AS_IF([test "x$with_xml2_config" = "xcheck"],
      [AC_PATH_PROG(XML2_CONFIG, xml2-config)],
      [test "x$with_xml2_config" != "xno"],
      [XML2_CONFIG="$with_xml2_config"])

AM_CONDITIONAL([WITH_LIBXML2], [test -n "$XML2_CONFIG"])

LIBXML2_LIBS=
LIBXML2_CFLAGS=
if [test -n "$XML2_CONFIG"]; then
    $XML2_CONFIG --version >/dev/null ||
        AC_MSG_ERROR([cannot execute $XML2_CONFIG])

    LIBXML2_LIBS="`$XML2_CONFIG --libs`"
    LIBXML2_CFLAGS="`$XML2_CONFIG --cflags`"
fi
AC_SUBST(LIBXML2_LIBS)
AC_SUBST(LIBXML2_CFLAGS)


AC_SUBST(LIBXML2_LIBS)
AC_SUBST(LIBXML2_CFLAGS)
 
AC_MSG_RESULT([libxml libs: ${LIBXML2_LIBS}])
AC_MSG_RESULT([libxml cflags: ${LIBXML2_CFLAGS}])
#
# Checks for features
#
AC_ARG_ENABLE(
    debug,
    AS_HELP_STRING([--enable-debug], [enable debugging features]),
    [], [enable_debug="no"])

AC_ARG_ENABLE(
    tests-install,
    AS_HELP_STRING([--enable-tests-install], [enable installation of tests]),
    [], [enable_tests_install="no"])

AC_ARG_ENABLE(
    opt,
    AS_HELP_STRING([--disable-opt],
                   [disable building options library (required by streams)]),
    [], [enable_opt="yes"])

AC_ARG_ENABLE(
    streams,
    AS_HELP_STRING([--disable-streams], [disable building stream library (required by formats)]),
    [], [enable_streams="yes"])

AC_ARG_ENABLE(
    formats,
    AS_HELP_STRING([--disable-formats], [disable building format library (required by hidrd-convert)]),
    [], [enable_formats="yes"])

AC_ARG_ENABLE(
    hidrd-convert,
    AS_HELP_STRING([--disable-hidrd-convert], [disable building hidrd-convert tool (requires formats)]),
    [], [enable_hidrd_convert="yes"])

AC_ARG_ENABLE(
    cmake-wrapper,
    AS_HELP_STRING([--enable-cmake-wrapper], [enable cmake wrapper for android]),
    [], [enable_cmake_wrapper="no"])

AC_ARG_ENABLE(
    tokens,
    AS_HELP_STRING([--disable-tokens],
                   [disable tokens (required by XML format)]),
    [], [enable_tokens="yes"])

AC_ARG_ENABLE(
    names,
    AS_HELP_STRING([--disable-names],
                   [disable names (required by XML format)]),
    [], [enable_names="yes"])

AC_ARG_ENABLE(
    xml-format,
    AS_HELP_STRING(
        [--disable-xml-format],
        [disable building XML format support (requires tokens, names and libxml2)]),
    [], [enable_xml_format="yes"])

AC_ARG_ENABLE(
    spec-format,
    AS_HELP_STRING(
        [--disable-spec-format],
        [disable building specification example format support (requires tokens and names)]),
    [], [enable_spec_format="yes"])

AC_ARG_ENABLE(
    code-format,
    AS_HELP_STRING(
        [--disable-code-format],
        [disable building source code format support (requires specification example format)]),
    [], [enable_code_format="yes"])

AC_CANONICAL_HOST


AC_ARG_ENABLE(
    android,
    AS_HELP_STRING(
        [--disable-android],
        [disable building android code format support)]),
    [], [
   case $host_os in
     *android*)
        enable_android="yes"
        ;;
     '')
       enable_android="no"
        ;;
     *)
        AC_MSG_NOTICE([android not present])
        ;;
    esac    
    ])


if test "$enable_android" == "yes"; then
  AC_MSG_NOTICE([compiling for an android build])
  AC_DEFINE(HAVE_ANDROID,1,[Define android])
fi

AC_ARG_WITH(xml2-config,
            AC_HELP_STRING([--with-xml2-config=PATH],
                           [Specify xml2-config location @<:@default=$PATH@:>@]),
            [],
            [with_xml2_config=check])

AC_ARG_WITH(armeabi,
            AC_HELP_STRING([--with-armeabi=[ARMEABI]],
                           [Specify the armeabi (x86,x86_64,armeabi-7a,arm64-v8a) @<:@default=$ARMEABI@:>@]),
            [],
            [with_armeabi=check])

AC_ARG_WITH(android-xml-schema-path,
            AC_HELP_STRING([--with-android-xml-schema-path=[PATH]],
                           [Specify the location of the xsd schema on the target system@<:@default=$PATH@:>@]),
            [],
            [with_android_xml_schema_path=check])

 
#check for asprintf and vasprintf - Android - Historically bionic exposes these. 
AC_CHECK_FUNC([asprintf],AC_DEFINE([HAVE_ASPRINTF], [], [Caution mingw32 will have no overflow protection]) ,) 
AC_CHECK_FUNC([vasprintf],AC_DEFINE([HAVE_VASPRINTF], [], [Caution mingw32 will have no overflow protection]) ,)
AC_CHECK_FUNC([bcopy],AC_DEFINE([HAVE_BCOPY], [], [mingw32 has no posix bcopy use memcopy instead. Android libc++ has moved this to a macro in NDK r11]) ,)

# Check for stream library dependencies
if test "$enable_streams" = "yes"; then
    if test "$enable_opt" != "yes"; then
        AC_MSG_WARN([option library is disabled, so disabling streams])
        enable_streams="no"
    fi
fi

# Check for format library dependencies
if test "$enable_formats" = "yes"; then
    if test "$enable_streams" != "yes"; then
        AC_MSG_WARN([stream library is disabled, so disabling formats])
        enable_formats="no"
    fi
fi

# Check for XML format dependencies
if test "$enable_xml_format" = "yes"; then
    if test "$enable_formats" != "yes"; then
        # Disable silently - quite obvious
        enable_xml_format="no"
    elif test "$enable_tokens" != "yes"; then
        AC_MSG_WARN([tokens are disabled, so disabling XML format])
        enable_xml_format="no"
    elif test "$enable_names" != "yes"; then
        AC_MSG_WARN([names are disabled, so disabling XML format])
        enable_xml_format="no"
    elif test -z "$XML2_CONFIG"; then
        AC_MSG_WARN([no xml2-config, so disabling XML format])
        enable_xml_format="no"
    fi
fi

# Check for spec format dependencies
if test "$enable_spec_format" = "yes"; then
    if test "$enable_formats" != "yes"; then
        # Disable silently - quite obvious
        enable_spec_format="no"
    elif test "$enable_tokens" != "yes"; then
        AC_MSG_WARN([tokens are disabled, so disabling specification example format])
        enable_spec_format="no"
    elif test "$enable_names" != "yes"; then
        AC_MSG_WARN([names are disabled, so disabling specification example format])
        enable_spec_format="no"
    fi
fi

# Check for code format dependencies
if test "$enable_code_format" = "yes"; then
    if test "$enable_spec_format" != "yes"; then
        AC_MSG_WARN([specification example format is disabled, so disabling source code format])
        enable_code_format="no"
    fi
fi

# Check hidrd-convert tool dependencies
if test "$enable_hidrd_convert" = "yes"; then
    if test "$enable_formats" != "yes"; then
        AC_MSG_WARN([format library is disabled, so disabling hidrd-convert tool])
        enable_hidrd_convert="no"
    fi
fi


# Output features to automake
AM_CONDITIONAL([ENABLE_TESTS_INSTALL], [test "$enable_tests_install" = "yes"])
AM_CONDITIONAL([ENABLE_OPT], [test "$enable_opt" = "yes"])
AM_CONDITIONAL([ENABLE_STRM], [test "$enable_streams" = "yes"])
AM_CONDITIONAL([ENABLE_FMT], [test "$enable_formats" = "yes"])
AM_CONDITIONAL([ENABLE_ANDROID], [test "$enable_android" == "yes"])
AM_CONDITIONAL([ENABLE_HIDRD_CONVERT], [test "$enable_hidrd_convert" = "yes"])
AM_CONDITIONAL([ENABLE_CMAKE_WRAPPER], [test "$enable_cmake_wrapper" == "yes"])
AM_CONDITIONAL([ENABLE_TOKENS], [test "$enable_tokens" = "yes"])
AM_CONDITIONAL([ENABLE_NAMES], [test "$enable_names" = "yes"])
AM_CONDITIONAL([ENABLE_FMT_XML], [test "$enable_xml_format" = "yes"])
AM_CONDITIONAL([ENABLE_FMT_SPEC], [test "$enable_spec_format" = "yes"])
AM_CONDITIONAL([ENABLE_FMT_CODE], [test "$enable_code_format" = "yes"])

# Remove Unicode reference for android
AM_CONDITIONAL(AH_VERBATIM([ENABLED_LIBXML_ICU], [#ifdef LIBXML_ICU_ENABLED
  #undef LIBXML_ICU_ENABLED
#endif]),[test "$enable_android" = "yes"])

# Output features to preprocessor and compiler
if test "$enable_debug" = "yes"; then
    CPPFLAGS="$CPPFLAGS -UNDEBUG"
    CFLAGS="$CFLAGS -g -O0"
fi

#
# Checks for header files.
#

#
# Checks for typedefs, structures, and compiler characteristics.
#

#
# Checks for declarations
#
if test -n "$XML2_CONFIG"; then
    CFLAGS_BACKUP="$CFLAGS"
    CFLAGS="$CFLAGS $LIBXML2_CFLAGS"
    AC_CHECK_DECLS([xmlStructuredErrorContext], [], [],
                   [[#include <libxml/globals.h>]])
    CFLAGS="$CFLAGS_BACKUP"
fi


#
# Checks for library functions.
#

#
# Output
#
AC_CONFIG_FILES([Makefile

                 m4/Makefile
                 m4/hidrd/Makefile

                 db/Makefile
                 db/usage/Makefile

                 include/Makefile
                 include/hidrd/Makefile
                 include/hidrd/util/Makefile
                 include/hidrd/item/Makefile
                 include/hidrd/item/pfx/Makefile
                 include/hidrd/opt/Makefile
                 include/hidrd/strm/Makefile
                 include/hidrd/strm/src/Makefile
                 include/hidrd/strm/snk/Makefile
                 include/hidrd/fmt/Makefile
                 include/hidrd/fmt/hex/Makefile
                 include/hidrd/fmt/natv/Makefile
                 include/hidrd/fmt/xml/Makefile
                 include/hidrd/fmt/spec/Makefile
                 include/hidrd/fmt/spec/snk/Makefile
                 include/hidrd/fmt/code/Makefile
                 include/hidrd/usage/Makefile
                 include/hidrd/adr/Makefile


                 lib/Makefile
                 lib/util/Makefile
                 lib/item/Makefile
                 lib/opt/Makefile
                 lib/strm/Makefile
                 lib/strm/src/Makefile
                 lib/strm/snk/Makefile
                 lib/fmt/Makefile
                 lib/fmt/hex/Makefile
                 lib/fmt/natv/Makefile
                 lib/fmt/xml/Makefile
                 lib/fmt/xml/snk/Makefile
                 lib/fmt/xml/src/Makefile
                 lib/fmt/read_test_data/Makefile
                 lib/fmt/write_test_data/Makefile
                 lib/fmt/spec/Makefile
                 lib/fmt/spec/snk/Makefile
                 lib/fmt/code/Makefile
                 lib/adr/Makefile
                 lib/usage/Makefile

                 src/Makefile])
AC_OUTPUT
