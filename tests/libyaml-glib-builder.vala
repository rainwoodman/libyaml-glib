using GLib.YAML;

public class Invoice: GLib.Object, Buildable {
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
	public Type get_child_type (Builder builder, string tag) {
		if(tag == "product") {
			return typeof(Product);
		}
		return Type.INVALID;
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
			bill_to.address.state,
			bill_to.address.postal);
		sb.append_printf("%s %s \n %s %s %s %s\n", 
			ship_to.given,
			ship_to.family,
			ship_to.address.lines,
			ship_to.address.city,
			ship_to.address.state,
			ship_to.address.postal);

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
	public string state {get; set;}
	public string postal {get; set;}
}

const string buffer =
"""
# This is the YAML 1.1 example. The YAML 1.2 example fails.
--- !Invoice
invoice: 34843
date   : 2001-01-23
bill-to: &id001
    given  : Chris
    family : Dumars
    address:
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
public static void main(string[] args) {
	Builder b = new Builder();
	b.add_from_string(buffer);
	Invoice invoice = b.get_root_object() as Invoice;
	stdout.printf("%s", invoice.summary());
	Writer w = new Writer();
	stdout.printf("%s", w.write_object(invoice));
}
