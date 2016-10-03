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
	 * Write an Object to a YAML string.
	 *
	 * For a BoxedType, implement a _to_string() member to
	 * return a newly allocated string represention of the object.
	 */
	public class Yaml.Writer {
		[CCode (has_target = false)]
		private delegate string StringFunc(void* boxed);
		public Writer(string? prefix = null) {
			this.prefix = prefix;
		}

		private string prefix = null;

		private unowned StringBuilder sb = null;
		Emitter emitter;

		public void stream_object(Object object, StringBuilder sb) throws Yaml.Exception {
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
			} catch (Yaml.Exception e) {
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
		private void write_object(Object object, bool write_type_tag = false)
		throws Yaml.Exception {
			Event event = {0};
			if(write_type_tag) {
				string type_name = object.get_type().name();
				if(prefix != null) {
					if(!type_name.has_prefix(prefix)) {
						throw new Yaml.Exception.WRITER (
						"object that is not in current namespace(%s)", prefix);
					}
					/* else */
					Event.mapping_start_initialize(ref event, null, "!" + type_name.substring(prefix.length), false);
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
				if(0 != (Buildable.get_property_hint_pspec(spec)
					& Buildable.PropertyHint.SKIP))
					/* skip the properties marked as SKIP */
					continue;
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

		private void write_children(Buildable buildable, string tag, Type type)
		throws Yaml.Exception {
			Event event = {0};
			Event.scalar_initialize(ref event, null, null, tag, (int)tag.length);
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

		private void write_property(Object object, ParamSpec pspec) 
		throws Yaml.Exception {
			Event event = {0};
			Event.scalar_initialize(ref event, null, null, pspec.name, (int)pspec.name.length);
			emitter.emit(ref event);
			Value value = Value(pspec.value_type);
			string str = null;
			object.get_property(pspec.name, ref value);

			if(pspec.value_type == typeof(int)) {
				str = value.get_int().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(uint)) {
				str = value.get_uint().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(long)) {
				str = value.get_long().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(ulong)) {
				str = value.get_ulong().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(string)) {
				str = value.dup_string();
				if(str == null) str = "~";
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(float)) {
				str = value.get_float().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(double)) {
				str = value.get_double().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(bool)) {
				str = value.get_boolean().to_string();
				write_scalar(ref event, str);
			} else
			if(pspec.value_type == typeof(Type)) {
				str = value.get_gtype().name();
				write_scalar(ref event, str);
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
				} else {
					str = "~";
					write_scalar(ref event, str);
				}
			} else
			if(pspec.value_type.is_a(Type.BOXED)) {
				void* string_symbol = Demangler.resolve_function(pspec.value_type.name(), "to_string");
				void* boxed_value = value.get_boxed();
				if(boxed_value == null) {
					str = "~";
				} else {
					StringFunc string_func = (StringFunc) string_symbol;
					str = string_func(boxed_value);
				}
				write_scalar(ref event, str);
			}  else
			if(pspec.value_type.is_a(Type.ENUM)) {
				EnumClass eclass = (EnumClass) pspec.value_type.class_ref();
				int e = value.get_enum();
				unowned EnumValue? evalue = eclass.get_value(e);
				if(evalue != null) {
					/* uppercase looks more enum really an issue of
					 * vala. enum nicks are all lowercase in vala. */
					str = evalue.value_nick.up();
				} else {
					str = e.to_string();
				}
				write_scalar(ref event, str);
			} else
			if(pspec.value_type.is_a(Type.FLAGS)) {
				FlagsClass fclass = (FlagsClass) pspec.value_type.class_ref();
				StringBuilder sb = new StringBuilder("");
				uint f = value.get_flags();
				unowned FlagsValue? fvalue = fclass.get_first_value(f);
				int i = 0;

				if(fvalue == null || fvalue.value == 0) {
					write_scalar(ref event, "~");
				} else {
					while(fvalue != null && fvalue.value != 0) {
						if(i > 0) sb.append(" | ");
						sb.append(fvalue.value_nick.up());
						f = f & ~fvalue.value;
						fvalue = fclass.get_first_value(f);
						i++;
					}
					write_scalar(ref event, sb.str);
				}
			}
			else {
				throw new Yaml.Exception.WRITER (
					"Unhandled property type %s",
					pspec.value_type.name());
			}
			Event.clean(ref event);
		}
		private void write_scalar(ref Event event, string str) {
			if(-1 != str.index_of_char(-1, '\n')) {
				Event.scalar_initialize(ref event, null, null, str, (int)str.length, true, true,
					ScalarStyle.LITERAL_SCALAR_STYLE);
			} else {
				Event.scalar_initialize(ref event, null, null, str, (int)str.length);
			}
			emitter.emit(ref event);
		}
		private int handler(char[] buffer) {
			sb.append_len((string)buffer, buffer.length);
			return 1;
		}
	}
