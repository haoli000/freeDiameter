conf_data = configuration_data()
configure_file(output : 'rt_rewrite-host.h',
                configuration : conf_data)

lgen = generator(flex,
    output : 'lex.@BASENAME@.c',
    arguments : ['-p', '-Cem', '-Prt_rewrite_conf', '-o', '@OUTPUT@', '@INPUT@']
    )
lfiles = lgen.process('rt_rewrite_conf.l')

pgen = generator(bison,
    output : ['@BASENAME@.tab.c', '@BASENAME@.tab.h'],
    arguments : ['-p', 'rt_rewrite_conf', '-d',
                 '@INPUT@', '--defines=@OUTPUT1@', '--output=@OUTPUT0@'])
pfiles = pgen.process('rt_rewrite_conf.y')

# List of source files
rt_rewrite_src = files(
    'rt_rewrite.c',
    'rt_rewrite.h'
)

shared_module('rt_rewrite',
    sources : [rt_rewrite_src, lfiles, pfiles],
    include_directories : freeDiameter_includes,
    dependencies : libfdcore_dep,
    name_prefix : '',
    name_suffix : 'fdx',
    install : true,
    install_dir : freeDiameter_extensionsdir)