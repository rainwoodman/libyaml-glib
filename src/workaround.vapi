public GLib.Type G_TYPE_BOXED;
public GLib.Type G_TYPE_ENUM;

public void g_type_set_qdata(GLib.Type type, GLib.Quark quark, void* data);
public void* g_type_get_qdata(GLib.Type type, GLib.Quark quark);
