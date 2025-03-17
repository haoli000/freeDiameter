# The dict_json extension

# Find required dependencies with fallbacks
jsoncpp_dep = dependency('jsoncpp', required : false)
if not jsoncpp_dep.found()
  # Try alternative names or methods
  jsoncpp_dep = dependency('libjsoncpp', required : false)
  if not jsoncpp_dep.found()
    # Try to find it manually if packaged differently
    jsoncpp_dep = declare_dependency(
      include_directories : include_directories('/usr/local/include/jsoncpp', '/usr/include/jsoncpp'),
      link_args : ['-ljsoncpp']
    )
    message('Using manual configuration for jsoncpp')
  endif
endif

# Similar approach for other dependencies
json_schema_dep = dependency('json-schema', required : false)
if not json_schema_dep.found()
  json_schema_dep = declare_dependency(
    include_directories : include_directories('/usr/local/include/json-schema', '/usr/include/json-schema'),
    link_args : ['-ljson-schema']
  )
  message('Using manual configuration for json-schema')
endif

pcrecpp_dep = dependency('libpcrecpp', required : false)
if not pcrecpp_dep.found()
  pcrecpp_dep = dependency('pcrecpp', required : false)
  if not pcrecpp_dep.found()
    pcrecpp_dep = declare_dependency(
      include_directories : include_directories('/usr/local/include', '/usr/include'),
      link_args : ['-lpcrecpp']
    )
    message('Using manual configuration for pcrecpp')
  endif
endif

# Build json-schema-to-c tool first
json_schema_to_c = executable('json-schema-to-c',
    sources : 'json-schema-to-c.cc',
    dependencies : [jsoncpp_dep, json_schema_dep, pcrecpp_dep],
    install : false
)

# Custom command to generate dict_json_dict_schema.cc
dict_json_dict_schema_gen = custom_target('dict_json_dict_schema',
    output : 'dict_json_dict_schema.cc',
    input : 'dict_json_dict_schema.json',
    command : [
        json_schema_to_c,
        '@INPUT@',
        '@OUTPUT@'
    ],
    depends : [json_schema_to_c]
)

# Build dict-json-diff tool
dict_json_diff = executable('dict-json-diff',
    sources : 'dict-json-diff.cc',
    dependencies : [jsoncpp_dep, json_schema_dep],
    install : true,
    install_dir : get_option('bindir')
)

# List of source files for the extension
dict_json_src = [
    'dict_json.cc',
    dict_json_dict_schema_gen
]

# Build the extension
shared_module('dict_json',
    sources : dict_json_src,
    dependencies : [libfdcore_dep, jsoncpp_dep, json_schema_dep],
    include_directories : [freeDiameter_includes, include_directories('.')],
    name_prefix : '',
    name_suffix : 'fdx',
    cpp_args : ['-std=c++11'],  # Add C++ compiler flags
    install : true,
    install_dir : freeDiameter_extensionsdir
)