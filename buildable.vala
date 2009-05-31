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
	public interface Buildable : Object {

		public virtual unowned string get_name() {
			return (string) this.get_data("buildable-name");
		}
		public virtual void set_name(string? name) {
			if(name != null) {
				this.set_data_full("buildable-name", Memory.dup(name, (int) name.size() + 1), g_free);
			} else {
				this.set_data("buildable-name", null);
			}
		}
		public virtual void add_child(Builder builder, Object child, string? type) throws GLib.Error {
			message("Adding %s to %s", (child as Buildable).get_name(), this.get_name());
		}

		public virtual Object? get_internal_child(Builder builder, string child_name) {
			return null;
		}

		public virtual Type get_child_type(Builder builder, string tag) {
			return Type.INVALID;
		}
		/* To workaround a vala limitation that the default interface implementation cannot be chained up.*/
		internal Type get_child_type_internal(Builder builder, string tag) {
			if(tag == "objects") return typeof(Object);
			if(tag == "internals") return typeof(Object);
			return get_child_type(builder, tag);
		}


		/**
		 * To avoid explicit dependency on libyaml-glib, node is defined as void*
		 * It is actually a GLib.YAML.Node
		 */
		public virtual void custom_node(Builder builder, string tag, void* node) throws GLib.Error {
			string message = "Property %s.%s not found".printf(get_type().name(), tag);
			throw new Error.PROPERTY_NOT_FOUND(message);
		}
	}
}
