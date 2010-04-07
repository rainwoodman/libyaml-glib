using GLib.YAML;

/****
 * Wrap buildable into a namespace prefix, so that the builder won't
 * build objects from our internal classes which shall never be built.
 * */
namespace Model {
	/*
	 * The main object each document is 1 invoice object.
	 * */
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

		/* Called by builder. when a child object is created
		 * the builder calls add_child to request the child being added
		 * to the invoice.
		 * */
		public void add_child(Builder builder, GLib.Object child, string? type) throws GLib.Error {
			products.prepend((Product)child);
		}

		/* declaring the types of child objects and corresponding yaml tags */
		private static const string[] tags = {"product"};
		private static Type[] types= {typeof(Product)};

		/* register the type with Buildable,
		 * This is actually due to a lack of static overridable methods
		 * in vala. */
		static construct {
			Buildable.register_type(typeof(Invoice), tags, types);
		}

		/* return the child elements for the given tag.
		 * Required by the writer */
		public List<unowned Object>? get_children(string? tag) {
			if(tag == "product") {
				/*NOTE: List.copy doesn't copy the reference counts of internal objects This might
				 * change in the future!*/
				return products.copy();
			}
			return null;
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

	/* Example on how to implement a struct.
	 * new_from_string returns an allocated struct element
	 * by parsing the string parameter.
	 * to_string() serializes the struct and returns a newly
	 * allocated string.
	 *
	 * This example is dumb.
	 * */
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

	/* Example on parsing enums */
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
}

public static void main(string[] args) {
	GLib.YAML.Builder b = new GLib.YAML.Builder("Model");
	try {
	var invoice = b.build_from_file(stdin) as Model.Invoice;
	invoice.foo = "This is a simple test";
	var w = new GLib.YAML.Writer();
	var sb = new StringBuilder("");
	w.stream_object(invoice, sb);
	stdout.printf("reprinted invoice\n");
	stdout.printf("%s\n", sb.str);
	} catch (GLib.YAML.Exception e) {
		error("%s", e.message);
	}
}
public static string summary(Model.Invoice invoice, StringBuilder? sb = null) {
	StringBuilder sb_ref = null;
	if(sb == null) {
		sb_ref = new StringBuilder("");
		sb = sb_ref;
	}
	sb.append_printf("%d\n", invoice.invoice);
	sb.append_printf("%s\n", invoice.date);
	sb.append_printf("%g\n", invoice.tax);
	sb.append_printf("%g\n", invoice.total);
	sb.append_printf("%s\n", invoice.comments);
	foreach(var o in invoice.get_children("products")) {
		var p = (Model.Product) o;
		sb.append_printf("%s %d %s %g\n", p.sku, p.quantity, p.description, p.price);
	}
	sb.append_printf("%s %s \n %s %s %s %s\n", 
		invoice.bill_to.given,
		invoice.bill_to.family,
		invoice.bill_to.address.lines,
		invoice.bill_to.address.city,
		invoice.bill_to.address.state.to_string(),
		invoice.bill_to.address.postal.code);
	sb.append_printf("%s %s \n %s %s %s %s\n", 
		invoice.ship_to.given,
		invoice.ship_to.family,
		invoice.ship_to.address.lines,
		invoice.ship_to.address.city,
		invoice.ship_to.address.state.to_string(),
		invoice.ship_to.address.postal.code);

	return sb.str;
}
