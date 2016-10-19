test('parser', executable('parser-test', 'libyaml-glib-parser.vala',
                          vala_args: ['--vapidir=' + meson.current_source_dir() + '/../src'],
                          dependencies: [glib, gobject, yaml, yaml_glib]),
     args: meson.current_source_dir() + '/invoice.yaml')
