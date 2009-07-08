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

		StringBuilder sb = null;
		public string write_object(Object object) throws Error {
			Event event = {0};
			Emitter emitter = Emitter();
			sb = new StringBuilder("");
			sb.truncate(0);
			emitter.set_output_file(stdout);

			Event.stream_start_initialize(ref event, EncodingType.ANY_ENCODING);
			emitter.emit(ref event);
			Event.document_start_initialize(ref event);
			emitter.emit(ref event);
			Event.sequence_start_initialize(ref event);
			emitter.emit(ref event);

			string s = "shitttttttaoidjfoaijfpqoifqewoifqpwoifqwoij";
			Event.scalar_initialize(ref event, null, null, (owned) s, 4);
			emitter.emit(ref event);
		
			Event.sequence_end_initialize(ref event);
			emitter.emit(ref event);
			Event.document_end_initialize(ref event);
			emitter.emit(ref event);
			Event.stream_end_initialize(ref event);
			emitter.emit(ref event);
			Event.clean(ref event);
			emitter.flush();
			return sb.str;
		}
		public int handler(char[] buffer) {
			message("shit");
			sb.append_len((string)buffer, buffer.length);
			return 0;
		}
	}
}
