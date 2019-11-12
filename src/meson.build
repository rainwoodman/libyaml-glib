sources = files(
  'buildable.vala',
  'builder.vala',
  'error.vala',
  'libyaml-glib.vala',
  'loader.vala',
  'writer.vala',
)

deps = [
  gobject_introspection_dep,
  yaml_dep,
  gmodule_dep,
]

revision = 0
current = 1
age = 0
current_minus_age = current - age
project_libversion = '@0@.@1@.@2@'.format(current_minus_age, age, revision)

libglib_yaml = shared_library(
  '@0@-@1@'.format(project_name, major_version),
  version: project_libversion,
  sources: sources,
  dependencies: deps,
  install: true,
  install_dir: [true, true, true],
)

libglib_yaml_dep = declare_dependency(
  include_directories: include_directories('.'),
  dependencies: deps,
  link_with: libglib_yaml,
)

glib_yaml_libname = '@0@-@1@'.format(project_name, project_version)

pkg = import('pkgconfig')

pkg.generate(
  libglib_yaml,
  filebase: glib_yaml_libname,
  name: 'glib-yaml',
  description: 'YAML parser library',
  subdirs: 'lib' + glib_yaml_libname,
  requires: deps,
)

gnome = import('gnome')

# GObject Introspection
enable_introspection = get_option('introspection')
if enable_introspection
  gnome.generate_gir(
    libglib_yaml,
    sources: sources,
    nsversion: project_version,
    includes: 'Gtk-3.0',
    namespace: 'YAML',
    identifier_prefix: 'Yaml',
    symbol_prefix: project_name,
    export_packages: glib_yaml_libname,
    header: 'glib-yaml.h',
    install: true,
  )
endif

