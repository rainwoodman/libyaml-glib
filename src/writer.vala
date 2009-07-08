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
	 * Internal class used to write the document
	 */
	internal class Writer {
		public Writer() {}

		private Document document;
		public bool write(ref Emitter emitter, Document document) throws Error {
			
			this.document = document;
			Event event;
			return true;
		}
	}
}
