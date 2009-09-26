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
			debug("Adding %s to %s", (child as Buildable).get_name(), this.get_name());
		}

		/**
		 * Register a type for buildable,
		 * especially register the child types.
		 * */
		public static void register_type (
			Type type,
			string[] tags, Type[] types) {
			g_type_set_qdata(type, Quark.from_string("buildable-child-tags"), tags);
			g_type_set_qdata(type, Quark.from_string("buildable-child-tags-len"), (void*) tags.length);
			g_type_set_qdata(type, Quark.from_string("buildable-child-types"), types);
			g_type_set_qdata(type, Quark.from_string("buildable-child-types-len"), (void*) types.length);
		}
		/**
		 * return a list of children types.
		 * the returned array should not be freed/modified.
		 * */
		public unowned string[]? get_child_tags() {
			void * pointer = g_type_get_qdata(this.get_type(), 
				Quark.from_string("buildable-child-tags"));
			unowned string[] tags = (string[]) pointer;
			tags.length = (int) g_type_get_qdata(this.get_type(), 
				Quark.from_string("buildable-child-tags-len"));
			return tags;
		}

		public unowned Type[]? get_child_types() {
			void * pointer = g_type_get_qdata(this.get_type(), 
				Quark.from_string("buildable-child-types"));
			unowned Type[] types = (Type[]) pointer;
			types.length = (int) g_type_get_qdata(this.get_type(), 
				Quark.from_string("buildable-child-types-len"));
			return types;
		}
		/**
		 * Return a list of children of the given type.
		 * @param type
		 *      if type == null, all children should be returned.
		 *
		 * the returned List doesn't hold references to the children.
		 * AKA, free the returned list but do not free the children.
		 * */
		public virtual List<unowned Object>? get_children(string? type) {
			return null;
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
		 * @deprecated
		 */
		internal Type get_child_type(Builder builder, string tag) {
			unowned string[] tags = get_child_tags();
			unowned Type[] types = get_child_types();
			/* if not so, there is a problem with your code */
			assert(types.length == tags.length);
			if(tags == null) return Type.INVALID;
			for(int i = 0; i < tags.length; i++) {
				if(tags[i] == tag) {
					return types[i];
				}
			}
			return Type.INVALID;
		}

		/**
		 * Processing the custom node.
		 *
		 * @param node
		 *   the node. It is actually a GLib.YAML.Node.
		 */
		public virtual void custom_node(Builder builder, string tag, GLib.YAML.Node node) throws GLib.Error {
			throw new Error.PROPERTY_NOT_FOUND(
				"Property %s.%s not found",
				get_type().name(), tag);
		}
	}
}
