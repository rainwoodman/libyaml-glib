/* ************
 *
 * Copyright (C) 2009  Yu Feng
 * Copyright (C) 2009  Denis Tereshkin
 * Copyright (C) 2009  Dmitriy Kuteynikov
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
 * 	Denis Tereshkin
 * 	Dmitriy Kuteynikov <kuteynikov@gmail.com>
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
	 * A YAML Node.
	 *
	 * YAML supports three types of nodes. They are converted to
	 * GTypes
	 *
	 *   [| ++YAML++ || ++GType++ |]
	 *   [| Scalar || Node.Scalar |]
	 *   [| Sequence || Node.Sequence |]
	 *   [| Mapping || Node.Mapping |]
	 *   [| Alias || Node.Alias |]
	 *
	 * Each node type utilizes the fundamental GLib types to store the
	 * YAML data.
	 *
	 * A pointer can be binded to the node with get_pointer and set_pointer.
	 * This pointer is used by GLib.YAML.Builder to hold the built object.
	 *
	 * */
	public class Node {
		public NodeType type;
		/**
		 * The tag of a node specifies its type.
		 **/
		public string tag;
		/**
		 * The start mark of the node in the YAML stream
		 **/
		public Mark start_mark;
		/**
		 * The end mark of the node in the YAML stream
		 **/
		public Mark end_mark;
		/**
		 * The anchor or the alias.
		 *
		 * The meanings of anchor differ for Alias node and other node types.
		 *  * For Alias it is the referring anchor,
		 *  * For Scalar, Sequence, and Mapping, it is the real anchor.
		 */
		public string anchor;

		private void* pointer;
		private DestroyNotify destroy_notify;
		/**
		 * Obtain the stored pointer in the node
		 */
		public void* get_pointer() {
			return pointer;
		}
		/**
		 * Store a pointer to the node.
		 * 
		 * @param notify
		 *   the function to be called when the pointer is freed
		 */
		public void set_pointer(void* pointer, DestroyNotify? notify = null) {
			if(this.pointer != null && destroy_notify != null) {
				destroy_notify(this.pointer);
			}
			this.pointer = pointer;
			destroy_notify = notify;
		}

		~Node () {
			if(this.pointer != null && destroy_notify != null) {
				destroy_notify(this.pointer);
			}
		}

		/**
		 * Obtain the resolved node to which this node is referring.
		 *
		 * Alias nodes are collapsed. This is indeed a very important
		 * function.
		 *
		 */
		public Node get_resolved() {
			if(this is Alias) {
				return (this as Alias).node.get_resolved();
			}
			return this;
		}

		public string get_location() {
			return "%s-%s".printf(start_mark.to_string(), end_mark.to_string());
		}
		/**
		 * An Alias Node
		 *
		 * Refer to the YAML 1.1 spec for the definitions.
		 *
		 * Note that the explanation of alias
		 * is different from the explanation of alias in standard YAML.
		 * The resolution of aliases are deferred, allowing forward-
		 * referring aliases; whereas in standard YAML, forward-referring
		 * aliases is undefined.
		 * */
		public class Alias:Node {
			public Node node;
		}
		/**
		 * A Scalar Node
		 *
		 * Refer to the YAML 1.1 spec for the definitions.
		 *
		 * The scalar value is internally stored as a string,
		 * or `gchar*'.
		 */
		public class Scalar:Node {
			public string value;
			public ScalarStyle style;
		}
		/**
		 * A Sequence Node
		 * 
		 * Refer to the YAML 1.1 spec for the definitions.
		 *
		 * The sequence is internally stored as a GList.
		 */
		public class Sequence:Node {
			public List<Node> items;
			public SequenceStyle style;
		}
		/**
		 * A Mapping Node
		 * 
		 * Refer to the YAML 1.1 spec for the definitions.
		 *
		 * The mapping is internally stored as a GHashTable.
		 *
		 * An extra list of keys is stored to ease iterating overall
		 * elements. GHashTable.get_keys is not available in GLib 2.12.
		 */
		public class Mapping:Node {
			public HashTable<Node, Node> pairs 
			= new HashTable<Node, Node>(direct_hash, direct_equal);
			public List<Node> keys;
			public MappingStyle style;
		}
	}
	/**
	 * A YAML Document
	 *
	 * Refer to the YAML 1.1 spec for the definitions.
	 *
	 * The document model based on GType classes replaces the original libyaml
	 * document model.
	 *
	 * [warning:
	 *  This is not a full implementation of a YAML document.
	 *  The document tag directive is missing.
	 *  Alias is not immediately resolved and replaced with the referred node.
	 * ]
	 */
	public class Document {
		/* List of nodes */
		public List<Node> nodes;
		public Mark start_mark;
		public Mark end_mark;
		/* Dictionary of anchors */
		public HashTable<string, Node> anchors
		= new HashTable<string, Node>(str_hash, str_equal);
		public Node root;
		/**
		 * Create a document from a parser
		 * */
		public Document.from_parser(ref Parser parser)
		throws GLib.YAML.Exception {
			Loader loader = new Loader();
			loader.load(ref parser, this);
		}

		/**
		 * Create a document from a string
		 * */
		public Document.from_string(string str)
		throws GLib.YAML.Exception {
			Loader loader = new Loader();
			Parser parser = Parser();
			parser.set_input_string(str, str.length);
			loader.load(ref parser, this);
		}

		/**
		 * Create a document from a file stream
		 * */
		public Document.from_file(FileStream file)
		throws GLib.YAML.Exception {
			Loader loader = new Loader();
			Parser parser = Parser();
			parser.set_input_file(file);
			loader.load(ref parser, this);
		}
	}


}
