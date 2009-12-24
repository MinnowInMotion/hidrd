/** @file
 * @brief HID report descriptor - basic item.
 *
 * Copyright (C) 2009 Nikolai Kondrashov
 *
 * This file is part of hidrd.
 *
 * Hidrd is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Hidrd is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with hidrd; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * @author Nikolai Kondrashov <spbnick@gmail.com>
 *
 * @(#) $Id$
 */

#include <string.h>
#include <stdio.h>
#include "hidrd/item/basic.h"


#ifdef HIDRD_WITH_TOKENS

char *
hidrd_item_basic_type_to_token(hidrd_item_basic_type type)
{
    assert(hidrd_item_basic_type_valid(type));

    switch (type)
    {
#define MAP(_NAME, _name) \
    case HIDRD_ITEM_BASIC_TYPE_##_NAME: \
        return strdup(#_name)

        MAP(MAIN,       main);
        MAP(GLOBAL,     global);
        MAP(LOCAL,      local);
        MAP(RESERVED,   reserved);

#undef MAP

        default:
            assert(!"Unknown basic item type");
            return NULL;
    }
}


char *
hidrd_item_basic_tag_to_token(hidrd_item_basic_tag tag)
{
    char   *token;

    assert(hidrd_item_basic_tag_valid(tag));

    if (asprintf(&token, "%u", tag) < 0)
        return NULL;

    return token;
}

#endif /* HIDRD_WITH_TOKENS */