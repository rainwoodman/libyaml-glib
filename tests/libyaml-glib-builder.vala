using GLib.YAML;

public class Object: GLib.Object, Buildable {
	public string tag {get; set;}
	private List<Object> children;
	public void add_child(Builder builder, GLib.Object child, string? type) throws GLib.Error {
		children.prepend((Object)child);
	}
	public Type get_child_type (Builder builder, string tag) {
		if(tag == "objects") {
			return typeof(Object);
		}
		return Type.INVALID;
	}
	public Object get_child(int id) {
		return children.nth(id).data as Object;
	}
}
public const string yaml = """
--- !Object &root
objects:
- tag : tag1
- tag : tag2
- tag : tag3
- tag : tag4
...
""";
public static void main(string[] args) {
	Builder b = new Builder();
	b.add_from_string(yaml);
	Object o = b.get_root_object() as Object;
	message("%s", o.get_child(0).tag);
	message("%s", o.get_child(1).tag);
	message("%s", o.get_child(2).tag);
}
