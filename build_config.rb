MRuby::Build.new do |conf|
  toolchain :clang

  if RUBY_PLATFORM =~ /darwin/
    conf.archiver.command = 'libtool'
    conf.archiver.archive_options = '-static -o %{outfile} %{objs}'
  end

  conf.gembox 'default'
  conf.gem File.expand_path(__dir__)
end
