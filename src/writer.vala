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
		public Writer() {}

		private static Type enum_type;
		private enum __enum {
			FOO,
		}
		static construct {
			enum_type = typeof(__enum).parent();
		}

		StringBuilder sb = null;
		Emitter emitter;
		public string stream_write_object(Object object) throws Error {
			Event event = {0};
			sb = new StringBuilder("");
			sb.truncate(0);
			emitter = Emitter();
			emitter.set_output(handler);

			Event.stream_start_initialize(ref event, EncodingType.ANY_ENCODING);
			emitter.emit(ref event);
			Event.document_start_initialize(ref event);
			emitter.emit(ref event);
			Event.clean(ref event);

			try {
				write_object(object);
			} catch (Error e) {
				throw e;
			} finally {
				Event.document_end_initialize(ref event);
				emitter.emit(ref event);
				Event.stream_end_initialize(ref event);
				emitter.emit(ref event);
				Event.clean(ref event);
				emitter.flush();
			}
			return sb.str;
		}
		private void write_object(Object object) throws Error {
			Event event = {0};
			Event.mapping_start_initialize(ref event);
			emitter.emit(ref event);

			ObjectClass klass = (ObjectClass) object.get_type().class_ref();
			ParamSpec[] specs = klass.list_properties();

			foreach(unowned ParamSpec spec in specs) {
				write_property(object, spec);
			}

		
			Event.mapping_end_initialize(ref event);
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
				write_object(value.get_object());
				str = null;
			} else
			if(pspec.value_type.is_a(typeof(Boxed))) {
				string message = "Unhandled property type %s".printf(pspec.value_type.name());
				throw new Error.UNKNOWN_PROPERTY_TYPE(message);
			}  else
			if(pspec.value_type.is_a(enum_type)) {
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
				string message = "Unhandled property type %s".printf(pspec.value_type.name());
				throw new Error.UNKNOWN_PROPERTY_TYPE(message);
			}
			if(str != null) {
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
