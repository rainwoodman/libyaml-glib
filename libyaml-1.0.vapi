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
 * 	Dmitriy Kuteynikov <kuteynikov@gmail.com>
 ***/

[CCode (cprefix="YAML", cheader_filename="yaml.h", lower_case_cprefix="yaml_")]
namespace YAML {

	[CCode (prefix="YAML_", cname="yaml_node_type_t", has_type_id=false)]
	public enum NodeType {
		NO_NODE,
		SCALAR_NODE,
		SEQUENCE_NODE,
		MAPPING_NODE
	}
	[CCode (prefix="YAML_", cname="yaml_scalar_style_t", has_type_id=false)]
	public enum ScalarStyle {
		ANY_SCALAR_STYLE,
		PLAIN_SCALAR_STYLE,
		SINGLE_QUOTED_SCALAR_STYLE,
		DOUBLE_QUOTED_SCALAR_STYLE,
		LITERAL_SCALAR_STYLE,
		FOLDED_SCALAR_STYLE
	}

	/** Sequence styles. */
	[CCode (prefix="YAML_", cname="yaml_sequence_style_t", has_type_id=false)]
	public enum SequenceStyle{
		/** Let the emitter choose the style. */
		ANY_SEQUENCE_STYLE,
		/** The block sequence style. */
		BLOCK_SEQUENCE_STYLE,
		/** The flow sequence style. */
		FLOW_SEQUENCE_STYLE
	}
	/** Mapping styles. */
	[CCode (prefix="YAML_", cname="yaml_mapping_style_t", has_type_id=false)]
	public enum MappingStyle {
		/** Let the emitter choose the style. */
		ANY_MAPPING_STYLE,
		/** The block mapping style. */
		BLOCK_MAPPING_STYLE,
		/** The flow mapping style. */
		FLOW_MAPPING_STYLE
		/*YAML_FLOW_SET_MAPPING_STYLE is not there*/
	}

	/** The version directive data. */
	[CCode (cname="yaml_version_directive_t", has_type_id = false)]
	public struct VersionDirective {
		/** The major version number. */
		public int major;
		/** The minor version number. */
		public int minor;
	}

	/** The tag directive data. */
	[CCode (cname = "yaml_tag_directive_t", has_type_id = false)]
	public struct TagDirective {
		/** The tag handle. */
		public string handle;
		/** The tag prefix. */
		public string prefix;
	}
	[CCode (cname="yaml_mark_t", has_type_id = false)]
	/** The pointer position. */
	public struct Mark {
		/** The position index. */
		public size_t index;

		/** The position line. */
		public size_t line;

		/** The position column. */
		public size_t column;
	}

	[CCode (cname = "yaml_event_type_t", cprefix="YAML_", has_type_id = false)]
	public enum EventType {
		/** An empty event. */
		NO_EVENT,

		/** A STREAM-START event. */
		STREAM_START_EVENT,
		/** A STREAM-END event. */
		STREAM_END_EVENT,

		/** A DOCUMENT-START event. */
		DOCUMENT_START_EVENT,
		/** A DOCUMENT-END event. */
		DOCUMENT_END_EVENT,

		/** An ALIAS event. */
		ALIAS_EVENT,
		/** A SCALAR event. */
		SCALAR_EVENT,

		/** A SEQUENCE-START event. */
		SEQUENCE_START_EVENT,
		/** A SEQUENCE-END event. */
		SEQUENCE_END_EVENT,

		/** A MAPPING-START event. */
		MAPPING_START_EVENT,
		/** A MAPPING-END event. */
		MAPPING_END_EVENT
	}

	[CCode (has_type_id = false)]
	/** The scalar parameters (for @c YAML_SCALAR_EVENT). */
	public struct EventScalar {
		/** The anchor. */
		public unowned string anchor;
		/** The tag. */
		public unowned string tag;
		/** The scalar value. */
		public unowned string value;
		/** The length of the scalar value. */
		public size_t length;
		/** Is the tag optional for the plain style? */
		public int plain_implicit;
		/** Is the tag optional for any non-plain style? */
		public int quoted_implicit;
	}

	[CCode (has_type_id=false)]
	public struct EventData {
		public YAML.EventScalar scalar;
	}

	[CCode (has_type_id = false,
			cname="yaml_event_t", 
			lower_case_cprefix="yaml_event_",
			destroy_function="yaml_event_delete")]
	public struct Event {
		[CCode (cname="yaml_stream_start_event_initialize")]
		public Event.stream_start(YAML.EncodingType encoding);
		public EventType type;
		public YAML.EventData data;
	}

	/** The stream encoding. */
	[CCode (cname = "yaml_encoding_t", cprefix="YAML_", has_type_id = false)]
	public enum EncodingType {
		/** Let the parser choose the encoding. */
		ANY_ENCODING,
		/** The default UTF-8 encoding. */
		UTF8_ENCODING,
		/** The UTF-16-LE encoding with BOM. */
		UTF16LE_ENCODING,
		/** The UTF-16-BE encoding with BOM. */
		UTF16BE_ENCODING
	}

	/** Many bad things could happen with the parser and emitter. */
	[CCode (cname="yaml_error_type_t", prefix="YAML_", has_type_id=false)]
	public enum ErrorType {
		/** No error is produced. */
		NO_ERROR,

		/** Cannot allocate or reallocate a block of memory. */
		MEMORY_ERROR,

		/** Cannot read or decode the input stream. */
		READER_ERROR,
		/** Cannot scan the input stream. */
		SCANNER_ERROR,
		/** Cannot parse the input stream. */
		PARSER_ERROR,
		/** Cannot compose a YAML document. */
		COMPOSER_ERROR,

		/** Cannot write to the output stream. */
		WRITER_ERROR,
		/** Cannot emit a YAML stream. */
		EMITTER_ERROR
	}

	[CCode (has_type_id = false,
			cname="yaml_parser_t", 
			lower_case_cprefix="yaml_parser_", 
			destroy_function="yaml_parser_delete")]
	public struct Parser {
		public YAML.ErrorType error;
		public string problem;
		public size_t problem_offet;
		public int problem_value;
		public YAML.Mark problem_mark;
		public string context;
		public YAML.Mark context_mark;

		[CCode (cname="yaml_parser_initialize")]
		public Parser();

		public void set_input_string(string input, size_t size);
		public void set_intput_file(GLib.FileStream file);
		public void set_encoding(YAML.EncodingType encoding);
		public int parse(out YAML.Event event);
	}

}
