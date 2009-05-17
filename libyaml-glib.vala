using YAML;
namespace GLib.YAML {
	public class Node {
		public NodeType type;
		public string tag;
		public Mark start_mark;
		public Mark end_mark;
		public class Scalar:Node {
			public string value;
			public ScalarStyle style;
		}
		public class Sequence:Node {
			public List<Node> items;
			public SequenceStyle style;
		}
		public class Mapping:Node {
			public HashTable<Node, Node> pairs;
			public HashTable<Node, Node> pairs_reverted;
			public MappingStyle style;
		}
	}
	public class Document {
		public List<Node> nodes;
		public VersionDirective version_directive;
		public List<TagDirective?> tag_directives;
		public bool start_implicit;
		public bool end_implicit;
		public Mark start_mark;
		public Mark end_mark;
	}
}
