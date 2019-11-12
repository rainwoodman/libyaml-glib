read_write_exec = executable(
    'read-write',
    sources: 'example-invoice.vala',
    dependencies: libglib_yaml_dep,
)

parse_exec = executable(
    'parser',
    sources: 'libyaml-glib-parser.vala',
    dependencies: libglib_yaml_dep,
)

test_files = files(
  'invoice.yaml',
)

foreach t : test_files
    test ('Parsing and output an invoice', read_write_exec, args: [t])
    test ('Parse test', parse_exec, args: [t])
endforeach
