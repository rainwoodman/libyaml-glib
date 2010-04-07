using GLib.YAML;

public class Invoice: GLib.Object, Buildable {
	public string foo {get; set;}
	public int invoice {get; set;}
	public string date {get; set;}
	public Contact bill_to {get; set;}
	public Contact ship_to {get; set;}
	public double tax {get; set;}
	public double total {get; set;}
	public string comments {get; set;}

	private List<Product> products;

	public void add_child(Builder builder, GLib.Object child, string? type) throws GLib.Error {
		products.prepend((Product)child);
	}
	private static const string[] tags = {"product"};
	private static Type[] types= {typeof(Product)};

	static construct {
		Buildable.register_type(typeof(Invoice), tags, types);
	}

	public List<unowned Object>? get_children(string? tag) {
		if(tag == "product") {
			/*NOTE: List.copy doesn't copy the reference counts of internal objects This might
			 * change in the future!*/
			return products.copy();
		}
		return null;
	}
	public string summary(StringBuilder? sb = null) {
		StringBuilder sb_ref = null;
		if(sb == null) {
			sb_ref = new StringBuilder("");
			sb = sb_ref;
		}
		sb.append_printf("%d\n", invoice);
		sb.append_printf("%s\n", date);
		sb.append_printf("%g\n", tax);
		sb.append_printf("%g\n", total);
		sb.append_printf("%s\n", comments);
		foreach(var p in products) {
			sb.append_printf("%s %d %s %g\n", p.sku, p.quantity, p.description, p.price);
		}
		sb.append_printf("%s %s \n %s %s %s %s\n", 
			bill_to.given,
			bill_to.family,
			bill_to.address.lines,
			bill_to.address.city,
			bill_to.address.state.to_string(),
			bill_to.address.postal.code);
		sb.append_printf("%s %s \n %s %s %s %s\n", 
			ship_to.given,
			ship_to.family,
			ship_to.address.lines,
			ship_to.address.city,
			ship_to.address.state.to_string(),
			ship_to.address.postal.code);

		return sb.str;
	}
}

public class Product : GLib.Object, Buildable {
	public string sku {get; set;}
	public int quantity {get; set;}
	public string description {get; set;}
	public double price {get; set;}
}
public class Contact : GLib.Object, Buildable {
	public string given {get; set;}
	public string family {get; set;}
	public Address address {get; set;}
}
public class Address : Object, Buildable {
	public string lines {get; set;}
	public string city {get; set;}
	public State state {get; set;}
	public Postal postal {get; set;}
}
public struct Postal {
	public string code;
	[CCode (array_length = false)]
	public static Postal[] new_from_string(string str) {
		Postal[] p = new Postal[1];
		p[0].code = str;
		return (owned) p;
	}
	public string to_string() {
		return code;
	}
}
[CCode (cprefix="")]
public enum State {
	PA,
	MI
	;
	public string to_string(){
		switch(this) {
			case State.MI:
				return "MI";
			case State.PA:
				return "PA";
			default:
				return "N/A";
		}
	}
}
public class MyAddress : Address {
}

public static void main(string[] args) {
	Builder b = new Builder(null);

	try {
	Invoice invoice = b.build_from_file(stdin) as Invoice;
	invoice.foo = "This is a simple test";
	Writer w = new Writer();
	StringBuilder sb = new StringBuilder("");
	w.stream_object(invoice, sb);
	stdout.printf("reprinted invoice\n");
	stdout.printf("%s\n", sb.str);
	} catch (GLib.YAML.Exception e) {
		error("%s", e.message);
	}
}
