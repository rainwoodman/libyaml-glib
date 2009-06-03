/* ************
 *
 * Copyright (C) 2009  Yu Feng
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to 
 *
 * the Free Software Foundation, Inc., 
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * Author:
 * 	Yu Feng <rainwoodman@gmail.com>
 ***/

using YAML;
namespace GLib.YAML {
	public errordomain Error {
		/* Demangler Could not find a symbol */
		SYMBOL_NOT_FOUND,

		/* Builder could not resolve a type*/
		TYPE_NOT_FOUND,
		NOT_A_BUILDABLE,
		PROPERTY_NOT_FOUND,
		OBJECT_NOT_FOUND,
		UNKNOWN_PROPERTY_TYPE,
		CUSTOM_NODE_ERROR,

		UNEXPECTED_NODE,
		NOT_IMPLEMENTED,

		FILE_NOT_FOUND,

		PARSER_ERROR,
		UNRESOLVED_ALIAS
	}
}
