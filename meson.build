project(
  'yaml-glib', ['c', 'vala'],
  version: '1.0.0',
  license: 'GPL3',
  default_options: 'buildtype=debugoptimized',
  meson_version: '>= 0.49.0',
)

project_name = meson.project_name()

project_version = meson.project_version()
version_array = project_version.split('.')
major_version = version_array[0].to_int()
minor_version = version_array[1].to_int()
micro_version = version_array[2].to_int()

gobject_introspection_dep = dependency('gobject-introspection-1.0', version: '>= 1.0')
yaml_dep = dependency('yaml-0.1', version: '>= 0.1')
gmodule_dep = dependency('gmodule-2.0', version: '>= 2.0')

source_root = meson.current_source_dir()
vapi_dir = join_paths(source_root, 'vapi')
add_project_arguments('--vapidir=' + vapi_dir, language: 'vala')


config_h = configuration_data()
set_defines = [
  ['PACKAGE_NAME', project_name],
  ['VERSION', project_version],
  ['GETTEXT_PACKAGE', project_name],
]

foreach define: set_defines
  config_h.set_quoted(define[0], define[1])
endforeach
valac = meson.get_compiler('vala')
config_dep = valac.find_library('config', dirs: vapi_dir)

subdir('src')
subdir('tests')

configure_file(
  output: 'config.h',
  configuration: config_h,
)

cc = meson.get_compiler('c')
source_root = meson.current_source_dir()

enable_gtk_doc = get_option('gtk_doc')
enable_man = get_option('man')

output = '\nConfiguration:\n\n'
output += '\tCompiler:                ' + cc.get_id() + '\n'
output += '\tSource code location:    ' + source_root + '\n'
output += '\tIntrospection Data:      ' + enable_introspection.to_string() + '\n\n'
output += '\tBuild Reference Manual:  ' + enable_gtk_doc.to_string() + '\n'
output += '\tBuild Manual Pages:      ' + enable_man.to_string()
message(output)

