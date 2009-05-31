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
 * 
 * This work is sponsed by C.Y Liu at Indiana University Cyclotron Facility.
 *
 ***/

using YAML;
namespace GLib.YAML {
	/**
	 * Buildable GObjects, from YAML.
	 *
	 *
	 * Objects that implements GLib.YAML.Buildable is buildable by
	 * GLib.YAML.Builder.
	 *
	 * This interface is almost the same as GtkBuildable.
	 *
	 **/
	public interface Buildable : Object {
		/**
		 * Set the anchor(name) of the object.
		 *
		 * The name is actually stored in `buildable-name' data member.
		 */
		public virtual unowned string get_name() {
			return (string) this.get_data("buildable-name");
		}
		/**
		 * get the anchor(name) of the object.
		 *
		 * The name is actually stored in `buildable-name' data member.
		 */
		public virtual void set_name(string? name) {
			if(name != null) {
				this.set_data_full("buildable-name", Memory.dup(name, (int) name.size() + 1), g_free);
			} else {
				this.set_data("buildable-name", null);
			}
		}
		/**
		 * Add a child to the buildable.
		 *
		 * @param type
		 *   the custom children type,
		 *   given as the key of the children sequence.
		 *
		 */
		public virtual void add_child(Builder builder, Object child, string? type) throws GLib.Error {
			message("Adding %s to %s", (child as Buildable).get_name(), this.get_name());
		}

		/**
		 * obtain an internal child.
		 *
		 * An internal child created by the buildable itself. As a contrary,
		 * an ordinary child is added to the buildable by the builder later on.
		 *
		 */
		public virtual Object? get_internal_child(Builder builder, string child_name) {
			return null;
		}

		/**
		 * Resolve the GType of the custom child node.
		 *
		 * All children in a custom child node are homogenous.
		 *
		 * @return the GType or G_TYPE_INVALID, 
		 *   if the tag is not a child_type tag.
		 */
		public virtual Type get_child_type(Builder builder, string tag) {
			return Type.INVALID;
		}
		/** 
		 * Internal function.
		 *
		 * To workaround a vala problem that 
		 * the default interface implementation cannot be chained up.
		 *
		 * */
		internal Type get_child_type_internal(Builder builder, string tag) {
			if(tag == "objects") return typeof(Object);
			if(tag == "internals") return typeof(Object);
			return get_child_type(builder, tag);
		}


		/**
		 * Processing the custom node.
		 *
		 * @param node
		 *   the node. It is actually a GLib.YAML.Node.
		 */
		public virtual void custom_node(Builder builder, string tag, void* node) throws GLib.Error {
			string message = "Property %s.%s not found".printf(get_type().name(), tag);
			throw new Error.PROPERTY_NOT_FOUND(message);
		}
	}
}
