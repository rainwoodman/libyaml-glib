yaml_glib_sources = [
    'buildable.vala',
    'builder.vala',
    'error.vala',
    'libyaml-glib.vala',
    'loader.vala',
    'writer.vala']
yaml_glib_lib = library('yaml-glib-1.0', yaml_glib_sources,
                    vala_args: ['--vapidir=' + meson.current_source_dir()],
                    dependencies: [glib, gobject, gmodule, yaml],
                    install: true)

yaml_glib = declare_dependency(link_with: yaml_glib_lib,
                               include_directories: include_directories('.'))

install_headers('yaml-glib-1.0.h')
install_data([meson.current_build_dir() + '/yaml-glib-1.0.vapi', 'yaml-glib-1.0.deps'],
             install_dir: 'share/vala/vapi')

pkgconfig = import('pkgconfig')
pkgconfig.generate(name: 'yaml-glib-1.0',
                   description: 'Building GObjects from YAML',
                   version: meson.project_version(),
                   requires: 'yaml-0.1',
                   libraries: yaml_glib_lib)
