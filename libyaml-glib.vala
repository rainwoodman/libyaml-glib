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
/*
 *
 * The GLib binding of libyaml.
 *
 * libyaml is used for parsing and emitting events.
 *
 * A document model based on GType classes replaces the original libyaml
 * document model.
 * 
 * [warning:
 *  This is not a full implementation of a YAML document.
 *  * The document tag directive is missing.
 *  * Alias is not immediately resolved and replaced with the referred node.
 * ]
 */
namespace GLib.YAML {
	public errordomain Error {
		PARSER_ERROR,
		UNRESOLVED_ALIAS
	}
	/**
	 * A YAML Node
	 * */
	public class Node {
		public NodeType type;
		public string tag;
		public Mark start_mark;
		public Mark end_mark;
		/* 
		 * The meanings of anchor differ for Alias node and other node types.
		 *
		 * For Alias it is the referring anchor,
		 * For Scalar, Sequence, and Mapping, it is the real anchor.
		 */
		public string anchor;

		private void* pointer;
		private DestroyNotify destroy_notify;
		public void* get_pointer() {
			return pointer;
		}
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
		 * An Alias Node
		 *
		 * Refer to the YAML 1.1 spec for the definitions.
		 * */
		public class Alias:Node {
			public Node node;
		}
		/**
		 * A Scalar Node
		 *
		 * Refer to the YAML 1.1 spec for the definitions.
		 */
		public class Scalar:Node {
			public string value;
			public ScalarStyle style;
		}
		/**
		 * A Sequence Node
		 * 
		 * Refer to the YAML 1.1 spec for the definitions.
		 */
		public class Sequence:Node {
			public List<Node> items;
			public SequenceStyle style;
		}
		/**
		 * A Mapping Node
		 * 
		 * Refer to the YAML 1.1 spec for the definitions.
		 */
		public class Mapping:Node {
			public HashTable<Node, Node> pairs 
			= new HashTable<Node, Node>(direct_hash, direct_equal);
			public HashTable<Node, Node> pairs_reverted
			= new HashTable<Node, Node>(direct_hash, direct_equal);
			public MappingStyle style;
		}
	}
	/**
	 * A YAML Document
	 *
	 * Refer to the YAML 1.1 spec for the definitions.
	 *
	 */
	public class Document {
		/* List of nodes */
		public List<Node> nodes;
		public Mark start_mark;
		public Mark end_mark;
		/* Dictionary of anchors */
		public HashTable<string, Node> anchors
		= new HashTable<string, Node>(str_hash, str_equal);
		
		/**
		 * Create a document from a parser
		 * */
		public Document.from_parser(ref Parser parser) throws Error {
			Loader loader = new Loader();
			loader.load(ref parser, this);
		}

		/**
		 * Create a document from a string
		 * */
		public Document.from_string(string str) throws Error {
			Loader loader = new Loader();
			Parser parser = Parser();
			parser.set_input_string(str, str.size());
			loader.load(ref parser, this);
		}
	}

	/**
	 * Internal class used to load the document
	 */
	internal class Loader {
		public Loader() {}
		private void parse_with_throw(ref Parser parser, out Event event)
		throws Error {
			if(parser.parse(out event)) {
				return;
			}
			string message =
			("Parser encounters an error: %s at %u(%s)\n"
			+"Error Context: '%s'")
			.printf(
				parser.problem,
				parser.problem_offset,
				parser.problem_mark.to_string(),
				parser.context
			);
			throw new Error.PARSER_ERROR(message);
		}
		private Document document;
		public bool load(ref Parser parser, Document document) 
		throws Error {
			this.document = document;
			Event event;
			/* Look for a StreamStart */
			if(!parser.stream_start_produced) {
				parse_with_throw(ref parser, out event);
				assert(event.type == EventType.STREAM_START_EVENT);
			}
			return_val_if_fail (!parser.stream_end_produced, true);

			parse_with_throw(ref parser, out event);
			/* if a StreamEnd seen, return OK */
			return_val_if_fail (event.type != EventType.STREAM_END_EVENT, true);

			/* expecting a DocumentStart otherwise */
			assert(event.type == EventType.DOCUMENT_START_EVENT);
			document.start_mark = event.start_mark;

			parse_with_throw(ref parser, out event);
			/* Load the first node. 
			 * load_node with recursively load other nodes */
			load_node(ref parser, ref event);
			
			/* expecting for a DocumentEnd */
			parse_with_throw(ref parser, out event);
			assert(event.type == EventType.DOCUMENT_END_EVENT);
			document.end_mark = event.end_mark;
			
			/* preserve the document order */
			document.nodes.reverse();

			/* resolve the aliases */
			foreach(Node node in document.nodes) {
				if(!(node is Node.Alias)) continue;
				var alias_node = node as Node.Alias;
				alias_node.node = document.anchors.lookup(alias_node.anchor);
				if(alias_node != null) continue;
				string message = "Alias '%s' cannot be resolved."
					.printf(alias_node.anchor);
				throw new Error.UNRESOLVED_ALIAS(message);
			}
			return true;
		}
		public Node load_node(ref Parser parser, ref Event last_event) 
		throws Error {
			switch(last_event.type) {
				case EventType.ALIAS_EVENT:
					return load_alias(ref parser, ref last_event);
				case EventType.SCALAR_EVENT:
					return load_scalar(ref parser, ref last_event);
				case EventType.SEQUENCE_START_EVENT:
					return load_sequence(ref parser, ref last_event);
				case EventType.MAPPING_START_EVENT:
					return load_mapping(ref parser, ref last_event);
				default:
					assert_not_reached();
			}
		}
		public Node? load_alias(ref Parser parser, ref Event event)
		throws Error {
			Node.Alias node = new Node.Alias();
			node.anchor = event.data.alias.anchor;

			/* Push the node to the document stack
			 * and register the anchor */
			document.nodes.prepend(node);
			if(node.anchor != null)
				document.anchors.insert(node.anchor, node);

			return node;
		}
		private static string normalize_tag(string? tag, string @default)
		throws Error {
			if(tag == null || tag == "!") {
				return @default;
			}
			return tag;
		}
		public Node? load_scalar(ref Parser parser, ref Event event)
		throws Error {
			Node.Scalar node = new Node.Scalar();
			node.anchor = event.data.scalar.anchor;
			node.tag = normalize_tag(event.data.scalar.tag,
					DEFAULT_SCALAR_TAG);
			node.value = event.data.scalar.value;
			node.style = event.data.scalar.style;
			node.start_mark = event.start_mark;
			node.end_mark = event.end_mark;

			/* Push the node to the document stack
			 * and register the anchor */
			document.nodes.prepend(node);
			if(node.anchor != null)
				document.anchors.insert(node.anchor, node);
			return node;
		}
		public Node? load_sequence(ref Parser parser, ref Event event)
		throws Error {
			Node.Sequence node = new Node.Sequence();
			node.anchor = event.data.sequence_start.anchor;
			node.tag = normalize_tag(event.data.sequence_start.tag,
					DEFAULT_SEQUENCE_TAG);
			node.style = event.data.sequence_start.style;
			node.start_mark = event.start_mark;
			node.end_mark = event.end_mark;

			/* Push the node to the document stack
			 * and register the anchor */
			document.nodes.prepend(node);
			if(node.anchor != null)
				document.anchors.insert(node.anchor, node);

			/* Load the items in the sequence */
			parse_with_throw(ref parser, out event);
			while(event.type != EventType.SEQUENCE_END_EVENT) {
				Node item = load_node(ref parser, ref event);
				/* prepend is faster than append */
				node.items.prepend(item);
				parse_with_throw(ref parser, out event);
			}
			/* Preserve the document order */
			node.items.reverse();

			/* move the end mark of the mapping
			 * to the END_SEQUENCE_EVENT */
			node.end_mark = event.end_mark;
			return node;
		}
		public Node? load_mapping(ref Parser parser, ref Event event)
		throws Error {
			Node.Mapping node = new Node.Mapping();
			node.tag = normalize_tag(event.data.mapping_start.tag,
					DEFAULT_MAPPING_TAG);
			node.anchor = event.data.mapping_start.anchor;
			node.style = event.data.mapping_start.style;
			node.start_mark = event.start_mark;
			node.end_mark = event.end_mark;

			/* Push the node to the document stack
			 * and register the anchor */
			document.nodes.prepend(node);
			if(node.anchor != null)
				document.anchors.insert(node.anchor, node);

			/* Load the items in the mapping */
			parse_with_throw(ref parser, out event);
			while(event.type != EventType.MAPPING_END_EVENT) {
				Node key = load_node(ref parser, ref event);
				parse_with_throw(ref parser, out event);
				Node value = load_node(ref parser, ref event);
				node.pairs.insert(key, value);
				node.pairs_reverted.insert(value, key);
				parse_with_throw(ref parser, out event);
			}
			/* move the end mark of the mapping
			 * to the END_MAPPING_EVENT */
			node.end_mark = event.end_mark;
			return node;
		}
	}

}
