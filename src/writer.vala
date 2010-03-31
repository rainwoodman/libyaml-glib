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
/**
 * The GLib binding of libyaml.
 *
 * libyaml is used for parsing and emitting events.
 *
 */
namespace GLib.YAML {
	/**
	 * Write an Object to a YAML string
	 */
	public class Writer {
		public Writer(string? prefix = null) {
			this.prefix = prefix;
		}

		private string prefix = null;
		private static Type enum_type;
		private enum __enum {
			FOO,
		}
		static construct {
			enum_type = typeof(__enum).parent();
		}

		private unowned StringBuilder sb = null;
		Emitter emitter;

		public void stream_object(Object object, StringBuilder sb) throws Error {
			Event event = {0};
			this.sb = sb;
			sb.truncate(0);
			emitter = Emitter();
			emitter.set_output(handler);

			Event.stream_start_initialize(ref event, EncodingType.ANY_ENCODING);
			emitter.emit(ref event);
			Event.document_start_initialize(ref event, null, null, null, false);
			emitter.emit(ref event);
			Event.clean(ref event);

			try {
				write_object(object, true);
			} catch (Error e) {
				throw e;
			} finally {
				Event.document_end_initialize(ref event);
				emitter.emit(ref event);
				Event.stream_end_initialize(ref event);
				emitter.emit(ref event);
				Event.clean(ref event);
				emitter.flush();
				this.sb = null;
			}
			return;
		}
		private void write_object(Object object, bool write_type_tag = false) throws Error {
			Event event = {0};
			if(write_type_tag) {
				string type_name = object.get_type().name();
				if(prefix != null) {
					if(type_name.has_prefix(prefix))
						Event.mapping_start_initialize(ref event, null, "!" + type_name.offset(prefix.length), false);
					else
						error("Internal program error, trying to serialize a object that is not in current namespace(%s)", prefix);
				} else {
					Event.mapping_start_initialize(ref event, null, "!" + type_name, false);
				}
			} else {
				Event.mapping_start_initialize(ref event);
			}
			emitter.emit(ref event);

			ObjectClass klass = (ObjectClass) object.get_type().class_ref();
			ParamSpec[] specs = klass.list_properties();

			foreach(unowned ParamSpec spec in specs) {
				write_property(object, spec);
			}
			if(object is Buildable) {
				Buildable buildable = object as Buildable;
				unowned string[] tags = buildable.get_child_tags();
				unowned Type[] types = buildable.get_child_types();
				if(tags != null)
				for(int i = 0; i < tags.length; i++) {
					write_children(buildable, tags[i], types[i]);
				}
			}
		
			Event.mapping_end_initialize(ref event);
			emitter.emit(ref event);
			Event.clean(ref event);
		}

		private void write_children(Buildable buildable, string tag, Type type) throws Error {
			Event event = {0};
			Event.scalar_initialize(ref event, null, null, tag, (int)tag.size());
			emitter.emit(ref event);

			List<weak Object> children = buildable.get_children(tag);

			Event.sequence_start_initialize(ref event);
			emitter.emit(ref event);
			foreach(weak Object child in children) {
				if(child.get_type() != type)
					write_object(child, true);
				else
					write_object(child, false);
			}
			Event.sequence_end_initialize(ref event);
			emitter.emit(ref event);
			Event.clean(ref event);
		}

		private void write_property(Object object, ParamSpec pspec) throws Error {
			Event event = {0};
			Event.scalar_initialize(ref event, null, null, pspec.name, (int)pspec.name.size());
			emitter.emit(ref event);
			Value value = Value(pspec.value_type);
			string str = "(*unsupported)";
			object.get_property(pspec.name, ref value);

			if(pspec.value_type == typeof(int)) {
				str = value.get_int().to_string();
			} else
			if(pspec.value_type == typeof(uint)) {
				str = value.get_uint().to_string();
			} else
			if(pspec.value_type == typeof(long)) {
				str = value.get_long().to_string();
			} else
			if(pspec.value_type == typeof(ulong)) {
				str = value.get_ulong().to_string();
			} else
			if(pspec.value_type == typeof(string)) {
				str = value.dup_string();
				if(str == null) str = "~";
			} else
			if(pspec.value_type == typeof(float)) {
				str = value.get_float().to_string();
			} else
			if(pspec.value_type == typeof(double)) {
				str = value.get_double().to_string();
			} else
			if(pspec.value_type == typeof(bool)) {
				str = value.get_boolean().to_string();
			} else
			if(pspec.value_type == typeof(Type)) {
				str = value.get_gtype().name();
			} else
			if(pspec.value_type.is_a(typeof(Object))) {
				unowned Object child = value.get_object();
				if(child!= null) {
					if(child.get_type() != pspec.value_type) {
						/* if the object type differs from the property
						 * schema, assume we have a child class instance
						 * therefore the type tag of this object is important
						 * */
						write_object(child, true);
					} else {
						write_object(child, false);
					}
					str = null;
				} else {
					str = "~";
				}
			} else
			if(pspec.value_type.is_a(Type.BOXED)) {
				throw new Error.UNKNOWN_PROPERTY_TYPE(
					"Unhandled property type %s",
					pspec.value_type.name());

			}  else
			if(pspec.value_type.is_a(Type.ENUM)) {
				EnumClass eclass = (EnumClass) pspec.value_type.class_ref();
				int e = value.get_enum();
				unowned EnumValue evalue = eclass.get_value(e);
				if(evalue != null) {
					str = evalue.value_name;
				} else {
					str = e.to_string();
				}
			}
			else {
				throw new Error.UNKNOWN_PROPERTY_TYPE(
					"Unhandled property type %s",
					pspec.value_type.name());
			}
			if(str != null) {
				/* FIXME: str != null is not a good indicator,
				 * use a boolean like need_scalar or something !*/
				if(null != str.chr(-1, '\n')) {
					Event.scalar_initialize(ref event, null, null, str, (int)str.size(), true, true,
						ScalarStyle.LITERAL_SCALAR_STYLE);
				} else {
					Event.scalar_initialize(ref event, null, null, str, (int)str.size());
				}
				emitter.emit(ref event);
			}
			Event.clean(ref event);
		}
		public int handler(char[] buffer) {
			sb.append_len((string)buffer, buffer.length);
			return 1;
		}
	}
}
