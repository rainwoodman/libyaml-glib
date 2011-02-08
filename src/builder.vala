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
	/**
	 * Building GObjects from a YAML stream.
	 *
	 * Refer to GLib.YAML.Buildable
	 *
	 * The root of the document is a mapping, which is built to an object.
	 * Other objects are inserted into children of the root object,
	 * supplied as items in sequences.
	 *
	 * ++ Two Stages of Building ++
	 * # First stage, Bootstrap.
	 *   an object is created for each mapping which has a YAML tag
	 *   corresponding to a valid GObject type.
	 * # Second stage, process values.
	 *   For every object created in bootstrap, scan the value nodes
	 *   for the corresponding mapping.
	 *   The keys in the mapping are processed as follows:
	 *   # `internals'
	 *     * Value: a mapping from internal child name to internal child.
	 *     * Requirements:
	 *         Buildable.get_internel_child() shall be implemented,
	 *         returning the child object for a key.
	 *   # `objects', other tags returned by get_child_tags.
	 *     * Value: a sequence of mapping that describes children objects.
	 *     * Requirements:
	 *         Declare type in the static or class constructer
	 *         with Buildable.register_type(type, child_tags, child_types);
	 *   # otherwise, assumed to be a property name
	 *     # Match with a property name of the object?
	 *       Parse the value accordingly and fill in the object value.
	 *       * If the property refers to an Object and the value node is
	 *         a mapping, a new object is created, and the object is
	 *         initialized by the supplied mapping.
	 *       * If the property refers to an Object and the value node is
	 *         an alias, the object referred by the alias is
	 *         assigned to the property.
	 *       * If the property type is a Boxed structure,
	 *         look for "_new_from_string" or "_parse" symbol of the type.
	 *         if _new_from_string is found, a new boxed element is created,
	 *         and assigned to the object.
	 *         otherwise, if _parse is found, a temperory buffer of
	 *         MAX_BOXED_SIZE bytes is allocated, and _parse is invoked to
	 *         fill in the buffer.
	 *       * _parse function conforms the calling convention of
	 *       gdk_color_parse ([CCode (instance_pos = -1)]
	 *   # signals
	 *     * Signal connection is not currently supported, but planned.
	 *   # custom nodes
	 *     * If the key doesn't match any of the priorly mentioned
	 *       catagories, Buildable.custom_node is invoked.
	 *     * If the buildable doesn't understand the node,
	 *       it should report a PROPERTY_NOT_FOUND error.
	 *
	 * [warning:
	 *   Be aware that if the Boxed struct is larger than the temporary buffer,
	 *   there will be a memory corruption. Currently no good fix is found,
	 *   because GLib doesn't store the size of a Boxed type.
	 *   Rule of thumb: Always implement _new_from_string(string)!
	 * ]
	 *
	 * Here is an example of the YAML file,
	 * which is semantically equivalent to the GtkBuilder example given in
	 * DevHelp, GtkBuildable.
	 *
	 * {{{
	 * --- !GtkDialog
	 * internals:
	 *   vbox : { border-width : 10 }
	 *   action-area :
	 *     border-width : 20
	 *     objects:
	 *       - !GtkHButtonBox &hbuttonbox1
	 *         objects:
	 *         - !GtkButton &ok_button
	 *           label: gtk-ok
	 *           use-stock: true
	 * }}}
	 *
	 * [warning:
	 *   Although this example is a valid YAML understood by the Builder,
	 *   it cannot be used to build the widgets, because GtkWidget
	 *   doesn't implement the required GYAMLBuildable interface.
	 * ]
	 *
	 *
	 * */
	public class Builder : GLib.Object {
		/*If a boxed type goes beyond this size, expect to crash */
		private static const int MAX_BOXED_SIZE = 65500;
		[CCode (has_target = false)]
		private delegate bool ParseFunc(string foo, void* location);
		[CCode (has_target = false)]
		private delegate void* NewFunc(string foo);
		private string prefix = null;
		private HashTable<string, unowned Object> anchors = new HashTable<string, unowned Object>.full(str_hash, str_equal, g_free, null);
		private List<Object> objects;

		private GLib.YAML.Document document;
		/**
		 * Create a builder with the given prefix.
		 **/
		public Builder(string? prefix = null) {
			this.prefix = prefix;
		}
		/**
		 * Add objects from a string
		 **/
		public void add_from_string(string str)
throws GLib.YAML.Exception {
			warning("this function is deprecated.");
			assert(document == null);
			document = new GLib.YAML.Document.from_string(str);
			bootstrap_objects(document);
			process_value_nodes();
		}
		/**
		 * Add objects from a file stream
		 **/
		public void add_from_file (FileStream file)
throws GLib.YAML.Exception {
			warning("this function is deprecated.");
			assert(document == null);
			document = new GLib.YAML.Document.from_file(file);
			bootstrap_objects(document);
			process_value_nodes();
		}

		/**
		 * Build an object from a given string
		 **/
		public Object? build_from_string(string str)
throws GLib.YAML.Exception {
			document = null;
			document = new GLib.YAML.Document.from_string(str);
			bootstrap_objects(document);
			process_value_nodes();
			return get_root_object();
		}

		/**
		 * Build an object from a given filestream
		 **/
		public Object? build_from_file(FileStream file)
throws GLib.YAML.Exception {
			document = null;
			document = new GLib.YAML.Document.from_file(file);
			bootstrap_objects(document);
			process_value_nodes();
			return get_root_object();
		}

		/**
		 * Build a object according to a given type. This function is
		 * intended to be used in implementing Buildable.custom_node .
		 *
		 * If the an object is already built for the node, it will return
		 * the built object.
		 *
		 * [warning:
		 *   Do not call this function in any places other than
		 *   the implementation of the Builable interface. It depends
		 *   on the internal data structures that are available only in
		 *   the object building process. Once the objects are built,
		 *   these data structures are destroyed.
		 * ]
		 *
		 * @param node
		 *   the node to build the object
		 * @param type
		 *   the expected type of the object
		 *
		 * @return the built object
		 */
		public Object build_object(GLib.YAML.Node node, Type type)
		throws GLib.YAML.Exception {
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

throws GLib.YAML.Exception {
			foreach(var node in document.nodes) {
				/* skip non objects */
				if(!(node is GLib.YAML.Node.Mapping)) continue;
				if(node.tag.get_char() != '!') continue;
				/* bootstrap all objects with sufficient information */
				bootstrap_object(node);
			}
		}

		private void process_value_nodes()
throws GLib.YAML.Exception {
			foreach(var obj in objects) {
				var node = obj.get_data<GLib.YAML.Node>("node");
				process_object_value_node(obj, node);
			}

		}

		/*
		 * Build a object without setting its properties and children,
		 * if type == Type.INVALID, the type is deducted from the node.tag.
		 */
		private Object bootstrap_object(GLib.YAML.Node node, Type type = Type.INVALID)
		throws GLib.YAML.Exception {
			string real_name = get_full_class_name(node.tag.next_char());
			if(node.get_pointer() != null) {
				return (Object) node.get_pointer();
			}

			if(type == Type.INVALID) type = Demangler.resolve_type(real_name);

			debug("creating object of type `%s'", type.name());
			Object obj = Object.new(type);
			((Buildable*) obj)->set_name(node.anchor);
			if(node.anchor != null) {
				anchors.insert(node.anchor, obj);
			}
			node.set_pointer(obj.ref(), g_object_unref);
			obj.set_data("node", node);
			objects.prepend(obj);
			return obj;
		}

		private Type get_child_type(Object obj, string tag) {
			Type type = ((Buildable*)obj) ->get_child_type(this, tag);
			if(type == Type.INVALID) {
				if(tag == "objects") return typeof(Object);
				if(tag == "internals") return typeof(Object);
			}
			return type;
		}

		private void process_object_value_node(Object obj, GLib.YAML.Node node)
throws GLib.YAML.Exception {
			var mapping = node as GLib.YAML.Node.Mapping;
			foreach(var key_node in mapping.keys) {
				weak string key = cast_to_scalar(key_node);
				var value_node = mapping.pairs.lookup(key_node).get_resolved();
				if(get_child_type(obj, key) != Type.INVALID) {
					process_children(obj, key, value_node);
					continue;
				}
				ParamSpec pspec = ((ObjectClass)obj.get_type().class_peek()).find_property(key);
				if(pspec != null) {
					if(0 == (Buildable.get_property_hint_pspec(pspec)
						& Buildable.PropertyHint.SKIP)) {
						process_property(obj, pspec, value_node);
					}
				} else {
					try {
						((Buildable*) obj)->custom_node(this, key, value_node);
					} catch (GLib.Error e) {
						throw new GLib.YAML.Exception.BUILDER(
						"%s: custom_node error: %s",
						node.get_location(),
						e.message);
					}
				}
			}

		}
		private void process_property(Object obj, ParamSpec pspec, GLib.YAML.Node node)
throws GLib.YAML.Exception {

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
						throw new GLib.YAML.Exception.BUILDER (
							"%s: Object '%s' not found",
							node.get_location(),
							cast_to_scalar(node));
					}
				} else
				if(node is GLib.YAML.Node.Mapping) {
					ref_obj = build_object(node, pspec.value_type);
				} else {
					throw new GLib.YAML.Exception.BUILDER (
						"%s: Excecting Scaler or Mapping for type `%s'",
						node.get_location(),
						pspec.name);
				}
				gvalue.set_object(ref_obj);
			} else
			if(pspec.value_type.is_a(Type.BOXED)) {
				var strval = cast_to_scalar(node);
				debug("working on a boxed type %s <- %s", pspec.value_type.name(), strval);
				try {
					void * new_symbol = Demangler.resolve_function(pspec.value_type.name(), "new_from_string");
					NewFunc new_func = (NewFunc) new_symbol;
					void* memory = new_func(strval);
					if(memory == null) {
						throw new GLib.YAML.Exception.BUILDER (
						"%s: boxed type `%s' parser failed",
						node.get_location(),
						pspec.value_type.name(),
						node.start_mark.to_string());
					}
					g_value_take_boxed(ref gvalue, memory);
				} catch (GLib.YAML.Exception.DEMANGLER e) {
					void * parse_symbol = Demangler.resolve_function(pspec.value_type.name(), "parse");
					ParseFunc parse_func = (ParseFunc) parse_symbol;
					void* memory = (void*) new char[MAX_BOXED_SIZE];
					warning("Allocating %d bytes for Boxed type %s.",
					MAX_BOXED_SIZE, pspec.value_type.name());
					if(!parse_func(strval, memory)) {
						throw new GLib.YAML.Exception.BUILDER (
						"%s: Boxed type `%s' parser failed",
						node.get_location(),
						pspec.value_type.name());
					}
					g_value_take_boxed(ref gvalue, memory);
				}
			}  else
			if(pspec.value_type.is_a(Type.ENUM)) {
				weak string name = cast_to_scalar(node);
				EnumClass eclass = (EnumClass) pspec.value_type.class_ref();
				unowned EnumValue? evalue = eclass.get_value_by_name(name);
				if(evalue == null)
					/* enum nicks are lowercase in vala*/
					evalue = eclass.get_value_by_nick(name.down());
				int e = 0;
				if(evalue == null) {
					weak string endptr = null;
					e = (int) name.to_int64(out endptr, 0);
					if((void*)endptr == (void*)name) {
						/* not actually an integer either */
						throw new GLib.YAML.Exception.BUILDER (
							"%s enum value `%s' is illegal",
							node.get_location(),
							name);
					}
				} else
					e = evalue.value;
				gvalue.set_enum(e);
			} else
			if(pspec.value_type.is_a(Type.FLAGS)) {
				weak string expression = cast_to_scalar(node);
				FlagsClass klass = (FlagsClass) pspec.value_type.class_ref();
				string[] names = expression.split("|");
				uint flags = 0; /* flag is 0 */
				foreach(weak string name in names) {
					uint f = 0;
					name._strip();
					if(name == "~") continue; /* null = 0 */
					/* try the full name first */
					unowned FlagsValue v = klass.get_value_by_name(name);
					if(v == null) {
					/* try the nick next */
					/* flags nicks are lowercase in vala, try the nick*/
						v = klass.get_value_by_nick(name.down());
					}
					if(v == null) {
						/* try if his is a raw number */
						weak string endptr = null;
						f = (uint) name.to_int64(out endptr, 0);
						if((void*)endptr == (void*)name) {
							/* not actually an integer either */
							throw new GLib.YAML.Exception.BUILDER (
							"%s flag value `%s' is illegal",
								node.get_location(),
								name);
						}
					} else {
						f = v.value;
					}
					flags |= f;
				}
				gvalue.set_flags(flags);
			}
			else {
				throw new GLib.YAML.Exception.UNIMPLEMENTED (
					"%s: Property `%s' type `%s' in unimplemented",
					node.get_location(),
					pspec.name,
					pspec.value_type.name());
			}
			obj.set_property(pspec.name, gvalue);
		}

		private unowned string cast_to_scalar(GLib.YAML.Node node)
		throws GLib.YAML.Exception {
			var value_scalar = (node as GLib.YAML.Node.Scalar);
			if(value_scalar == null) {
				throw new GLib.YAML.Exception.BUILDER (
					"%s: Expecting scalar.",
					node.get_location());
			}
			return value_scalar.value;
		}

		private void process_internal_children(Object obj, GLib.YAML.Node node)
		throws GLib.YAML.Exception {
			var children = node as GLib.YAML.Node.Mapping;
			foreach(var key_node in children.keys) {
				var key = cast_to_scalar(key_node);
				var value_node = children.pairs.lookup(key_node).get_resolved();
				Object child = ((Buildable*) obj)->get_internal_child(this, key);
				if(child == null) {
					throw new GLib.YAML.Exception.BUILDER (
					"%s: Expecting internal child `%s'",
					node.get_location(), key);
				}
				process_object_value_node(child, value_node);
			}
		}

		private void process_children(Object obj, string type, GLib.YAML.Node node)
		throws GLib.YAML.Exception {
			if(type == "internals") {
				process_internal_children(obj, node);
				return;
			}
			var children = node as GLib.YAML.Node.Sequence;
			foreach(var item in children.items) {
				var child = build_object(item.get_resolved(), ((Buildable*)obj)->get_child_type(this, type));
				assert(child != null);
				try {
					((Buildable*)obj)->add_child(this, child, type);
				} catch (GLib.Error e) {
					throw new GLib.YAML.Exception.BUILDER(
					"%s: add_child error %s",
					node.get_location(),
					e.message);
				}
			}
		}
		/**
		 * Obtain a built object referred by the anchor, or the root object
		 * of the latest added document if anchor == null.
		 *
		 * @return the object referred by the anchor or the root object.
		 *
		  */
		public Object? get_object(string? anchor) {
			if(anchor != null)
			return anchors.lookup(anchor);
			else
			return get_root_object();
		}

		/**
		 * Obtain the root object created for the document
		 *
		 * @return the root object
		 */
		public Object? get_root_object() {
			return document.root.get_pointer() as Object;
		}
		/**
		 * Obtain a list of all objects created by the builder. The
		 * returned list should not be modified.
		 *
		 * @return a read-only weak reference to the list of all objects
		 * created by the builder.
		 */
		public unowned List<Object>? get_objects() {
			return objects;
		}
	}
	/**
	 * Demangle vala names to c names in the standard way.
	 *
	 * [warning:
	 *   GI information is not used, therefore
	 *   if there is any special tricks by the CCode annotations,
	 *   you have to be careful and understand what you are doing.
	 * ]
	 **/
	internal static class Demangler {
		/**
		 * A yet powerful Vala type name to c name demangler.
		 *
		 * @param vala_name
		 *   the class name. eg, UCN.ColdNeutron
		 *
		 * */
		public static string demangle(string vala_name) {
			StringBuilder sb = new StringBuilder("");

			bool already_underscoped = true;
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
		/**
		 * Resolve a member function to a function pointer.
		 *
		 * @param class_name
		 *   the name of the class, usually from GType.name(),
		 * @param member_name
		 *   the name of the member.
		 *
		 * @return the function pointer.
		 */
		public static void * resolve_function(string class_name,
				string member_name)
		throws GLib.YAML.Exception.DEMANGLER {
			void * symbol;
			StringBuilder sb = new StringBuilder("");
			sb.append(Demangler.demangle(class_name));
			sb.append_unichar('_');
			sb.append(Demangler.demangle(member_name));
			string func_name = sb.str;
			Module self = Module.open(null, 0);
			if(!self.symbol(func_name, out symbol)) {
				throw new GLib.YAML.Exception.DEMANGLER (
					"Symbol %s.%s (%s) not found",
					class_name, member_name, func_name);
			}
			return symbol;
		}
		[CCode (has_target = false)]
		private delegate Type TypeFunc();
		/**
		 * Resolve a GType from the class_name.
		 *
		 * Notice that GType.from_name is not used, instead, the get_type
		 * static member is called to obtain the name.
		 * This is necessary because the type we are looking for might
		 * have not yet been registered to the type system, whereas the
		 * get_type functions are mandatory for any GType classes.
		 *
		 * @return the GType
		 */
		public static Type resolve_type(string class_name)
		throws GLib.YAML.Exception {
			void* symbol = resolve_function(class_name, "get_type");
			TypeFunc type_func = (TypeFunc) symbol;
			return type_func();
		}
	}
}
