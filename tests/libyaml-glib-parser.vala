using YAML;
using Yaml;
const string buffer =
"""
# This is the YAML 1.1 example. The YAML 1.2 example fails.
--- !Invoice
status : SHIPPED | CANCELLED 
invoice: 34843
date   : 2001-01-23
bill-to: &id001
    given  : Chris
    family : Dumars
    address: !PaypalAddress
        verified: true
        lines: |
            458 Walkman Dr.
            Suite #292
        city    : Royal Oak
        state   : MI
        postal  : 48046
ship-to: *id001
product:
    - sku         : BL394D
      quantity    : 4
      description : Basketball
      price       : 450.00
    - sku         : BL4438H
      quantity    : 1
      description : Super Hoop
      price       : 2392.00
tax  : 251.42
total: 4443.52
comments:
    Late afternoon is best.
    Backup contact is Nancy
    Billsmer @ 338-4338.


""";
bool use_internal = false;
[CCode (array_length = false, array_null_terminated = true)]
string[] filename = null;
const OptionEntry[] options = {
    {"internal", 'i', 0, OptionArg.NONE, ref use_internal, "Use the internal Yaml 1.1 example", null},
    {"",0, 0, OptionArg.FILENAME_ARRAY, ref filename, "the file to be parsed", null},
    {null}
};

FileStream stream = null;

public int main(string[] args) {
    OptionContext context = new OptionContext(" - test the parser");
    context.add_main_entries (options, null);
    context.parse(ref args);

    YAML.Parser parser = YAML.Parser();

    if(use_internal)
        parser.set_input_string(buffer, buffer.length);
    else {
        if(filename != null) {
            stream = FileStream.open(filename[0], "r");
            assert(filename.length == 1);
            assert(stream != null);
        }
        if(stream != null)
            parser.set_input_file(stream);
        else
            parser.set_input_file(stdin);
    }
    try {
        Document document = new Document.from_parser(ref parser);
        foreach(Yaml.Node node in document.nodes) {
            if(node is Yaml.Node.Scalar) {
                message("node:(%p) %s", node, (node as Yaml.Node.Scalar).value);
            } else
                if(node is Yaml.Node.Alias) {
                    message("alias:(%p) %s -> %p", 
                            node,
                            (node as Yaml.Node.Alias).node.anchor,
                            (node as Yaml.Node.Alias).get_resolved()
                           );
                } else 
                    if(node is Yaml.Node.Mapping) {
                        message("mapping:(%p)", node);
                    } else 
                        if(node is Yaml.Node.Sequence) {
                            message("sequence:(%p)", node);
                        }
        }
    } catch (Error e) {
        message("error message: %s", e.message);
    }
    return 0;
}
