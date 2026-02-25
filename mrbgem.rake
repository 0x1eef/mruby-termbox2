MRuby::Gem::Specification.new('mruby-termbox2') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Piotr Usewicz'
  spec.summary = 'MRuby bindings for termbox2 terminal I/O library'
  spec.version = '0.1.0'
  spec.homepage = 'https://github.com/pusewicz/mruby-termbox2'
  spec.cc.include_paths << "#{dir}/lib/termbox2"
end
