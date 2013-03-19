# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{bud}
  s.version = "0.9.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Peter Alvaro", "Neil Conway", "Joseph M. Hellerstein", "William R. Marczak", "Sriram Srinivasan"]
  s.date = %q{2013-02-25}
  s.description = %q{A prototype of the Bloom distributed programming language as a Ruby DSL.}
  s.email = ["bloomdevs@gmail.com"]
  s.executables = ["rebl", "budplot", "budvis", "budtimelines", "budlabel"]
  s.files = ["lib/bud/aggs.rb", "lib/bud/bud_meta.rb", "lib/bud/collections.rb", "lib/bud/depanalysis.rb", "lib/bud/errors.rb", "lib/bud/executor/elements.rb", "lib/bud/executor/group.rb", "lib/bud/executor/join.rb", "lib/bud/executor/README.rescan", "lib/bud/graphs.rb", "lib/bud/labeling/bloomgraph.rb", "lib/bud/labeling/budplot_style.rb", "lib/bud/labeling/labeling.rb", "lib/bud/lattice-core.rb", "lib/bud/lattice-lib.rb", "lib/bud/meta_algebra.rb", "lib/bud/metrics.rb", "lib/bud/monkeypatch.rb", "lib/bud/rebl.rb", "lib/bud/rewrite.rb", "lib/bud/rtrace.rb", "lib/bud/server.rb", "lib/bud/source.rb", "lib/bud/state.rb", "lib/bud/storage/dbm.rb", "lib/bud/storage/zookeeper.rb", "lib/bud/viz.rb", "lib/bud/viz_util.rb", "lib/bud.rb", "bin/budlabel", "bin/budplot", "bin/budtimelines", "bin/budvis", "bin/rebl", "docs/bfs.md", "docs/bfs_arch.png", "docs/bloom-loop.png", "docs/cheat.md", "docs/getstarted.md", "docs/intro.md", "docs/modules.md", "docs/operational.md", "docs/README.md", "docs/rebl.md", "docs/ruby_hooks.md", "docs/visualizations.md", "examples/basics/hello.rb", "examples/basics/paths.rb", "examples/chat/chat.rb", "examples/chat/chat_protocol.rb", "examples/chat/chat_server.rb", "examples/chat/README.md", "examples/README.md", "README.md", "LICENSE", "History.txt"]
  s.homepage = %q{http://www.bloom-lang.org}
  s.licenses = ["BSD"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.8.7")
  s.rubyforge_project = %q{bloom-lang}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A prototype Bloom DSL for distributed programming.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 4

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_runtime_dependency(%q<fastercsv>, [">= 0"])
      s.add_runtime_dependency(%q<getopt>, [">= 0"])
      s.add_runtime_dependency(%q<msgpack>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-graphviz>, [">= 0"])
      s.add_runtime_dependency(%q<ruby2ruby>, [">= 2.0.1"])
      s.add_runtime_dependency(%q<ruby_parser>, [">= 3.1.0"])
      s.add_runtime_dependency(%q<superators19>, [">= 0"])
      s.add_runtime_dependency(%q<syntax>, [">= 0"])
      s.add_runtime_dependency(%q<uuid>, [">= 0"])
      s.add_development_dependency(%q<minitest>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<fastercsv>, [">= 0"])
      s.add_dependency(%q<getopt>, [">= 0"])
      s.add_dependency(%q<msgpack>, [">= 0"])
      s.add_dependency(%q<ruby-graphviz>, [">= 0"])
      s.add_dependency(%q<ruby2ruby>, [">= 2.0.1"])
      s.add_dependency(%q<ruby_parser>, [">= 3.1.0"])
      s.add_dependency(%q<superators19>, [">= 0"])
      s.add_dependency(%q<syntax>, [">= 0"])
      s.add_dependency(%q<uuid>, [">= 0"])
      s.add_dependency(%q<minitest>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<fastercsv>, [">= 0"])
    s.add_dependency(%q<getopt>, [">= 0"])
    s.add_dependency(%q<msgpack>, [">= 0"])
    s.add_dependency(%q<ruby-graphviz>, [">= 0"])
    s.add_dependency(%q<ruby2ruby>, [">= 2.0.1"])
    s.add_dependency(%q<ruby_parser>, [">= 3.1.0"])
    s.add_dependency(%q<superators19>, [">= 0"])
    s.add_dependency(%q<syntax>, [">= 0"])
    s.add_dependency(%q<uuid>, [">= 0"])
    s.add_dependency(%q<minitest>, [">= 0"])
  end
end
