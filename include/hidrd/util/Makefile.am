#
# Copyright (C) 2010 Nikolai Kondrashov
# Amendments 2018 Anthony Campbell
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

hidrd_utildir = $(includedir)/hidrd/util

hidrd_util_HEADERS = \
    bit.h               \
    bool.h              \
    buf.h               \
    char.h              \
    dec.h               \
    fd.h                \
    fmt.h               \
    hex.h               \
    num.h               \
    str.h               \
    ttbl.h              \
    unit.h

if ADD_OBSTACK
hidrd_util_HEADERS  += obstacklocal.h
endif

if ENABLE_TOKENS
hidrd_util_HEADERS += tkn.h
endif
