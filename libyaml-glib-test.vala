using YAML;
using GLib.YAML;
const string buffer =
"""
A: B
""";
public int main(string[] args) {
	Parser parser = Parser();
	Event event;
	parser.set_input_string(buffer, buffer.size());
	Document document = new Document.load(ref parser);

	return 0;
}
