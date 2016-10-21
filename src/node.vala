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
 * A YAML Node.
 *
 * YAML supports three types of nodes. They are converted to
 * GTypes
 *
 *   [| ++YAML++ || ++GType++ |]
 *   [| Scalar || Node.Scalar |]
 *   [| Sequence || Node.Sequence |]
 *   [| Mapping || Node.Mapping |]
 *   [| Alias || Node.Alias |]
 *
 * Each node type utilizes the fundamental GLib types to store the
 * YAML data.
 *
 * A pointer can be binded to the node with get_pointer and set_pointer.
 * This pointer is used by Yaml.Builder to hold the built object.
 *
 * */
public abstract class Yaml.Node : Object {
	/**
	 * The tag of a node specifies its type.
	 **/
	public string tag { get; construct; }
	/**
	 * The start mark of the node in the YAML stream
	 **/
	public Mark? start_mark { get; set; default = null; }
	/**
	 * The end mark of the node in the YAML stream
	 **/
	public Mark? end_mark { get; set; default = null; }
	/**
	 * The anchor or the alias.
	 *
	 * The meanings of anchor differ for Alias node and other node types.
	 *  * For Alias it is the referring anchor,
	 *  * For Scalar, Sequence, and Mapping, it is the real anchor.
	 */
	public string anchor { get; construct set; }

	private void* pointer;
	private DestroyNotify destroy_notify;
	/**
	 * Obtain the stored pointer in the node
	 */
	public void* get_pointer() {
		return pointer;
	}
	/**
	 * Store a pointer to the node.
	 * 
	 * @param notify
	 *   the function to be called when the pointer is freed
	 */
	public void set_pointer(void* pointer, DestroyNotify? notify = null) {
		if(this.pointer != null && destroy_notify != null) {
			destroy_notify(this.pointer);
		}
		this.pointer = pointer;
		destroy_notify = notify;
	}

	~Node () {
		if(this.pointer != null && destroy_notify != null) {
			destroy_notify(this.pointer);
		}
	}

	/**
	 * Obtain the resolved node to which this node is referring.
	 *
	 * Alias nodes are collapsed. This is indeed a very important
	 * function.
	 *
	 */
	public Node get_resolved() {
		if(this is Alias) {
			return (this as Alias).node.get_resolved();
		}
		return this;
	}

	public string get_location() {
		return "%s-%s".printf(start_mark.to_string(), end_mark.to_string());
	}
}
