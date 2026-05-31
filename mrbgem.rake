load File.join(__dir__, 'mrblib', 'termbox2', 'version.rb')

MRuby::Gem::Specification.new('mruby-termbox2') do |spec|
  spec.license = 'MIT'
  spec.author  = 'Piotr Usewicz'
  spec.summary = 'MRuby bindings for termbox2 terminal I/O library'
  spec.version = Termbox2::VERSION
  spec.homepage = 'https://github.com/pusewicz/mruby-termbox2'
  spec.cc.include_paths << "#{dir}/lib/termbox2"
end
