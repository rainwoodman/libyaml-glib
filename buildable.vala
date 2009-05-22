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
	public interface Buildable : Object {
		private static delegate bool ParseFunc(string foo, void* location);

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

		public virtual Type get_child_type(Builder builder, string tag) {
			return Type.INVALID;
		}
		/* To workaround a vala limitation that the default interface implementation cannot be chained up.*/
		internal Type get_child_type_internal(Builder builder, string tag) {
			if(tag == "objects") return typeof(Object);
			return get_child_type(builder, tag);
		}

		internal void process_children(Builder builder, string type, GLib.YAML.Node node) throws Error {
			var children = node as GLib.YAML.Node.Sequence;
			foreach(var item in children.items) {
				var child = (Object) item.get_resolved().get_pointer();
				if (child == null) {
					var message = "Expecting an object, found nothing (%s)".printf(node.start_mark.to_string());
					throw new Error.OBJECT_NOT_FOUND(message);
				}
				add_child(builder, child, type);
			}
		}
		internal unowned string cast_to_scalar(GLib.YAML.Node node) throws Error {
			var value_scalar = (node as GLib.YAML.Node.Scalar);
			if(value_scalar == null) {
				string message = "Expecting a Scalar (%s)"
				.printf(node.start_mark.to_string());
				throw new Error.UNEXPECTED_NODE(message);
			}
			return value_scalar.value;
		}
		internal void process_property(Builder builder, ParamSpec pspec, GLib.YAML.Node node) throws Error {

			Value gvalue = Value(pspec.value_type);
			if(pspec.value_type == typeof(int)) {
				gvalue.set_int((int)cast_to_scalar(node).to_long());
			} else
			if(pspec.value_type == typeof(uint)) {
				gvalue.set_uint((uint)cast_to_scalar(node).to_long());
			} else
			if(pspec.value_type == typeof(long)) {
				gvalue.set_long(cast_to_scalar(node).to_long());
			} else
			if(pspec.value_type == typeof(ulong)) {
				gvalue.set_ulong(cast_to_scalar(node).to_ulong());
			} else
			if(pspec.value_type == typeof(string)) {
				gvalue.set_string(cast_to_scalar(node));
			} else
			if(pspec.value_type == typeof(float)) {
				gvalue.set_float((float)cast_to_scalar(node).to_double());
			} else
			if(pspec.value_type == typeof(double)) {
				gvalue.set_double(cast_to_scalar(node).to_double());
			} else
			if(pspec.value_type == typeof(bool)) {
				gvalue.set_boolean(cast_to_scalar(node).to_bool());
			} else
			if(pspec.value_type == typeof(Type)) {
				gvalue.set_gtype(Demangler.resolve_type(builder.get_full_class_name(cast_to_scalar(node))));
			} else
			if(pspec.value_type.is_a(typeof(Object))) {
				Object ref_obj = null;
				if(node is GLib.YAML.Node.Scalar) {
					ref_obj = builder.get_object(cast_to_scalar(node));
					if(ref_obj == null) {
						string message = "Object '%s' not found".printf(cast_to_scalar(node));
						throw new Error.OBJECT_NOT_FOUND(message);
					}
				}
				if(node is GLib.YAML.Node.Mapping) {
					ref_obj = builder.build_object(node, pspec.value_type);
				}
				gvalue.set_object(ref_obj);
			} else
			if(pspec.value_type.is_a(typeof(Boxed))) {
				var strval = cast_to_scalar(node);
				message("working on a boxed type %s <- %s", pspec.value_type.name(), strval);
				void* symbol = Demangler.resolve_function(pspec.value_type.name(), "parse");
				char[] memory = new char[65500];
				ParseFunc func = (ParseFunc) symbol;
				if(!func(strval, (void*)memory)) {
					string message = "Failed to parse the boxed type %s at (%s)"
					.printf(pspec.value_type.name(), node.start_mark.to_string());
					throw new Error.UNEXPECTED_NODE(message);
				}
				gvalue.set_boxed(memory);
			} else {
				string message = "Unhandled property type %s".printf(pspec.value_type.name());
				throw new Error.UNKNOWN_PROPERTY_TYPE(message);
			}
			this.set_property(pspec.name, gvalue);
			
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
