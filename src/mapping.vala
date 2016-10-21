/* ************
 *
 * Copyright (C) 2009  Yu Feng
 * Copyright (C) 2009  Denis Tereshkin
 * Copyright (C) 2009  Dmitriy Kuteynikov
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
 * 	Denis Tereshkin
 * 	Dmitriy Kuteynikov <kuteynikov@gmail.com>
 ***/

using YAML;

/**
 * A Mapping Node
 * 
 * Refer to the YAML 1.1 spec for the definitions.
 *
 * The mapping is internally stored as a GHashTable.
 *
 * An extra list of keys is stored to ease iterating overall
 * elements. GHashTable.get_keys is not available in GLib 2.12.
 */
public class Yaml.Mapping : Node {

	public MappingStyle style { get; construct; }

	public Gee.Map<Node, Node> pairs { get; construct; }

	public Mapping (MappingStyle style) {
		Object (style: style, pairs: new Gee.HashMap<Node, Node> ());
	}
}
