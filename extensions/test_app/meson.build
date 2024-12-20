conf_data = configuration_data()
if cc.has_header_symbol('regex.h', 'REG_STARTEND')
  conf_data.set('HAVE_REG_STARTEND', 1)
endif
configure_file(output : 'test_app-host.h',
                configuration : conf_data)


lgen = generator(flex,
    output : 'lex.@BASENAME@.c',
    arguments : ['-p', '-Cem', '-Pta_conf', '-o', '@OUTPUT@', '@INPUT@']
    )
lfiles = lgen.process('ta_conf.l')

pgen = generator(bison,
    output : ['@BASENAME@.tab.c', '@BASENAME@.tab.h'],
    arguments : ['-p', 'ta_conf', '-d',
                 '@INPUT@', '--defines=@OUTPUT1@', '--output=@OUTPUT0@'])
pfiles = pgen.process('ta_conf.y')

# List of source files
test_app_src = files(
	'ta_bench.c',
	'ta_cli.c',
	'ta_dict.c',
	'ta_serv.c',
	'test_app.h',
	'test_app.c',
)

shared_module('test_app',
    sources : [test_app_src, lfiles, pfiles],
    include_directories : freeDiameter_includes,
    dependencies : libfdcore_dep,
    name_prefix : '',
    name_suffix : 'fdx',
    install : true,
    install_dir : freeDiameter_extensionsdir)
