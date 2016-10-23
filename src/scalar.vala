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
 * A Scalar Node
 *
 * Refer to the YAML 1.1 spec for the definitions.
 *
 * The scalar value is internally stored as a string,
 * or `gchar*'.
 */
public class Yaml.Scalar : Node {

	public ScalarStyle style { get; construct; }

	public string value { get; construct set; }

	public Scalar (ScalarStyle style = YAML.ScalarStyle.ANY_SCALAR_STYLE) {
		Object (style: style);
	}
}
