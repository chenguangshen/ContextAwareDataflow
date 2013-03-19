# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{docile}
  s.version = "1.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Marc Siegel"]
  s.date = %q{2012-11-29}
  s.description = %q{Docile turns any Ruby object into a DSL. Especially useful with the Builder pattern.}
  s.email = ["msiegel@usainnov.com"]
  s.files = [".gitignore", ".travis.yml", ".yardopts", "Gemfile", "LICENSE", "README.md", "Rakefile", "docile.gemspec", "lib/docile.rb", "lib/docile/fallback_context_proxy.rb", "lib/docile/version.rb", "spec/docile_spec.rb", "spec/spec_helper.rb"]
  s.homepage = %q{http://ms-ati.github.com/docile/}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{docile}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Docile keeps your Ruby DSL's tame and well-behaved}
  s.test_files = ["spec/docile_spec.rb", "spec/spec_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<rake>, [">= 0.9.2"])
      s.add_development_dependency(%q<rspec>, [">= 2.11.0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
      s.add_development_dependency(%q<redcarpet>, [">= 0"])
      s.add_development_dependency(%q<github-markup>, [">= 0"])
    else
      s.add_dependency(%q<rake>, [">= 0.9.2"])
      s.add_dependency(%q<rspec>, [">= 2.11.0"])
      s.add_dependency(%q<yard>, [">= 0"])
      s.add_dependency(%q<redcarpet>, [">= 0"])
      s.add_dependency(%q<github-markup>, [">= 0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 0.9.2"])
    s.add_dependency(%q<rspec>, [">= 2.11.0"])
    s.add_dependency(%q<yard>, [">= 0"])
    s.add_dependency(%q<redcarpet>, [">= 0"])
    s.add_dependency(%q<github-markup>, [">= 0"])
  end
end
