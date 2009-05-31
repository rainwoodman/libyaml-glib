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
 ***/

using YAML;

namespace GLib.YAML {
	public class Builder : GLib.Object {
		private static delegate bool ParseFunc(string foo, void* location);
		private string prefix = null;
		private HashTable<string, Object> anchors = new HashTable<string, Object>(str_hash, str_equal);
		private List<Object> objects;

		private GLib.YAML.Document document;
		public Builder(string? prefix = null) {
			this.prefix = prefix;
		}
		public void add_from_string(string str) throws GLib.Error {
			assert(document == null);
			document = new GLib.YAML.Document.from_string(str);
			bootstrap_objects(document);
			process_value_nodes();
		}
		public void add_from_file (FileStream file) throws GLib.Error {
			assert(document == null);
			document = new GLib.YAML.Document.from_file(file);
			bootstrap_objects(document);
			process_value_nodes();
		}

		/**
		 * Build a object according to a given type
		 */
		public Object build_object(GLib.YAML.Node node, Type type) throws GLib.Error {
			if(node.get_pointer() != null) {
				return (Object) node.get_pointer();
			}
			Object obj = bootstrap_object(node, type);
			process_object_value_node(obj, node);
			return obj;
		}

		private string get_full_class_name(string class_name) {
			if(prefix != null)
				return prefix + "." + class_name;
			else
				return class_name;
		}

		private void bootstrap_objects(GLib.YAML.Document document) 
		throws GLib.Error {
			foreach(var node in document.nodes) {
				/* skip non objects */
				if(!(node is GLib.YAML.Node.Mapping)) continue;
				if(node.tag.get_char() != '!') continue;
				/* bootstrap all objects with sufficient information */
				bootstrap_object(node);
			}
		}

		private void process_value_nodes() throws GLib.Error {
			foreach(var obj in objects) {
				var node = (GLib.YAML.Node)obj.get_data("node");
				process_object_value_node(obj, node);
			}
			
		}

		/* 
		 * Build a object without setting its properties and children
		 * if type == Type.INVALID, the type is deducted from the node.tag.
		 */
		private Object bootstrap_object(GLib.YAML.Node node, Type type = Type.INVALID) throws GLib.Error {
			string real_name = get_full_class_name(node.tag.next_char());
			if(node.get_pointer() != null) {
				return (Object) node.get_pointer();
			}
			try {
				if(type == Type.INVALID) type = Demangler.resolve_type(real_name);

				message("%s", type.name());
				Object obj = Object.new(type);
				if(!(obj is Buildable)) {
					string message = 
					"Object type %s(%s) is not a buildable"
					.printf(type.name(), node.start_mark.to_string());
					throw new Error.NOT_A_BUILDABLE(message);
				}
				Buildable buildable = obj as Buildable;
				buildable.set_name(node.anchor);
				if(node.anchor != null) {
					anchors.insert(node.anchor, obj);
				}
				node.set_pointer(obj.ref(), g_object_unref);
				obj.set_data("node", node);
				objects.prepend(obj);
				return obj;
			} catch (Error.SYMBOL_NOT_FOUND e) {
				string message =
				"Type %s(%s) is not found".
				printf(real_name, node.start_mark.to_string());
				throw new Error.TYPE_NOT_FOUND(message);
			}
		}

		private void process_object_value_node(Object obj, GLib.YAML.Node node) throws GLib.Error {
			Buildable buildable = obj as Buildable;
			var mapping = node as GLib.YAML.Node.Mapping;
			foreach(var key_node in mapping.keys) {
				weak string key = cast_to_scalar(key_node);
				var value_node = mapping.pairs.lookup(key_node).get_resolved();
				if(buildable.get_child_type_internal(this, key) != Type.INVALID) {
					process_children(buildable, key, value_node);
					continue;
				}
				ParamSpec pspec = ((ObjectClass)obj.get_type().class_peek()).find_property(key);
				if(pspec != null) {
					process_property(buildable, pspec, value_node);
				} else {
					buildable.custom_node(this, key, value_node);
				}
			}
			
		}
		private void process_property(Buildable buildable, ParamSpec pspec, GLib.YAML.Node node) throws Error {

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
				gvalue.set_gtype(Demangler.resolve_type(get_full_class_name(cast_to_scalar(node))));
			} else
			if(pspec.value_type.is_a(typeof(Object))) {
				Object ref_obj = null;
				if(node is Node.Scalar) {
					ref_obj = get_object(cast_to_scalar(node));
					if(ref_obj == null) {
						string message = "Object '%s' not found".printf(cast_to_scalar(node));
						throw new Error.OBJECT_NOT_FOUND(message);
					}
				}
				if(node is GLib.YAML.Node.Mapping) {
					ref_obj = build_object(node, pspec.value_type);
				} else {
					string message = "Donot know how to build the object for `%s' (%s)"
					.printf(pspec.name,  node.start_mark.to_string());
					throw new Error.OBJECT_NOT_FOUND(message);
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
			buildable.set_property(pspec.name, gvalue);
		}

		private unowned string cast_to_scalar(GLib.YAML.Node node) throws Error {
			var value_scalar = (node as GLib.YAML.Node.Scalar);
			if(value_scalar == null) {
				string message = "Expecting a Scalar (%s)"
				.printf(node.start_mark.to_string());
				throw new Error.UNEXPECTED_NODE(message);
			}
			return value_scalar.value;
		}

		private void process_internal_children(Buildable buildable, GLib.YAML.Node node) throws GLib.Error {
			var children = node as GLib.YAML.Node.Mapping;
			foreach(var key_node in children.keys) {
				var key = cast_to_scalar(key_node);
				var value_node = children.pairs.lookup(key_node).get_resolved();
				Object child = buildable.get_internal_child(this, key);
				if(child == null) {
					var message = "Expecting an internal child `%s', found nothing (%s)"
					.printf(key, node.start_mark.to_string());
					throw new Error.OBJECT_NOT_FOUND(message);
				}
				process_object_value_node(child, value_node);
			}
		}

		private void process_children(Buildable buildable, string type, GLib.YAML.Node node) throws GLib.Error {
			if(type == "internals") {
				process_internal_children(buildable, node);
				return;
			}
			var children = node as GLib.YAML.Node.Sequence;
			foreach(var item in children.items) {
				var child = (Object) item.get_resolved().get_pointer();
				if (child == null) {
					var message = "Expecting an object, found nothing (%s)".printf(node.start_mark.to_string());
					throw new Error.OBJECT_NOT_FOUND(message);
				}
				buildable.add_child(this, child, type);
			}
		}
		/** 
		 * if anchor == null, return the object built by the root node of the yaml file
		 * Do not throw exceptions.
		 */
		public Object? get_object(string? anchor) {
			if(anchor != null)
			return anchors.lookup(anchor);
			else 
			return document.root.get_pointer() as Object;
		}
		public unowned List<Object>? get_objects() {
			return objects;
		}
	}
	/**
	 * Demangle vala names to c names in the standard way.
	 **/
	internal static class Demangler {
		/**
		 * A yet powerful Vala type name to c name demangler.
		 *
		 * vala_class_name: the class name. eg, UCN.ColdNeutron
		 *
		 * [ warning:
		 *   Notice that GI information is not used, therefore
		 *   the CCode annotation is not awared.
		 * ]
		 * */
		public static string demangle(string vala_name) {
			StringBuilder sb = new StringBuilder("");

			bool already_underscoped = false;
			unowned string p0 = null;
			unowned string p1 = vala_name;
			unichar c0 = 0;
			unichar c1 = p1.get_char();
			for(;
			    c1 != 0;
			    p0 = p1, c0 = c1, p1 = p1.next_char(), c1 = p1.get_char()) {

				/* Do not take any real action before we have two chars. */
				if(c0 == 0) continue;

				if(c0.islower() && c1.isupper()) {
					sb.append_unichar(c0.tolower());
					sb.append_unichar('_');
					already_underscoped = true;
					continue;
				}
				if(c0.isupper() && c1.islower()) {
					if(!already_underscoped) {
						sb.append_unichar('_');
					}
					sb.append_unichar(c0.tolower());
					already_underscoped = false;
					continue;
				}
				
				if(c0 == '.') {
					sb.append_unichar('_');
					already_underscoped = true;
					continue;
				} else {
					sb.append_unichar(c0.tolower());
					already_underscoped = false;
					continue;
				}
			}
			sb.append_unichar(c0.tolower());
			return sb.str;
		}
		public static void * resolve_function(string class_name, 
				string member_name) throws Error {
			void * symbol;
			StringBuilder sb = new StringBuilder("");
			sb.append(Demangler.demangle(class_name));
			sb.append_unichar('_');
			sb.append(Demangler.demangle(member_name));
			string func_name = sb.str;
			Module self = Module.open(null, 0);
			if(!self.symbol(func_name, out symbol)) {
				string message =
				"Symbol %s.%s (%s) not found"
				.printf(class_name, member_name, func_name);
				throw new Error.SYMBOL_NOT_FOUND(message);
			}
			return symbol;
		}
		private static delegate Type TypeFunc();
		public static Type resolve_type(string class_name) throws Error {
			void* symbol = resolve_function(class_name, "get_type");
			TypeFunc type_func = (TypeFunc) symbol;
			return type_func();
		}
	}
}
