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
public class Yaml.Document : Node {

	public Node root { get; construct set; }

	/* List of nodes */
	public Gee.List<Node> nodes { get; construct; }

	/* Dictionary of anchors */
	public Gee.Map<string, Node> anchors { get; construct; }

	public Document () {
		Object (nodes: new Gee.ArrayList<Node> (), anchors: new Gee.HashMap<string, Node> ());
	}

	/**
	 * Create a document from a parser
	 * */
	public Document.from_parser(ref Parser parser)
	throws Yaml.Exception {
		this ();
		Loader loader = new Loader();
		loader.load(ref parser, this);
	}

	/**
	 * Create a document from a string
	 * */
	public Document.from_string(string str)
	throws Yaml.Exception {
		Parser parser = Parser();
		parser.set_input_string(str, str.length);
		this.from_parser (ref parser);
	}

	/**
	 * Create a document from a file stream
	 * */
	public Document.from_file(FileStream file)
	throws Yaml.Exception {
		Parser parser = Parser();
		parser.set_input_file(file);
		this.from_parser (ref parser);
	}
}
