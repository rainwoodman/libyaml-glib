using YAML;
const string buffer =
"""
A: B
""";
public int main(string[] args) {
	Parser parser = Parser();
	Event event;
	parser.set_input_string(buffer, buffer.size());
	bool done = false;
	while(!done) {
		parser.parse(out event);
		switch(event.type) {
			case EventType.STREAM_END_EVENT:
				message("stream end");
				done = true;
			break;
			case EventType.SCALAR_EVENT:
				message("scalar: %s", event.data.scalar.value);
			break;
		}
	}
	return 0;
}
