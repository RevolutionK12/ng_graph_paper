# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "ng_graph_paper"
  s.version = "1.0.12"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["krisfox"]
  s.date = "2014-03-10"
  s.description = "AngularJS Graphing Paper tool"
  s.email = "krisfox@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".ruby-gemset",
    ".ruby-version",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/assets/javascripts/directives.js.coffee",
    "lib/assets/javascripts/evaluator.js.coffee",
    "lib/assets/javascripts/module.js.coffee",
    "lib/assets/javascripts/ng_graph_paper.js",
    "lib/ng_graph_paper.rb",
    "lib/ng_graph_paper/engine.rb",
    "ng_graph_paper.gemspec",
    "test/helper.rb",
    "test/test_ng_graph_paper.rb"
  ]
  s.homepage = "http://github.com/krisfox/ng_graph_paper"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.25"
  s.summary = "AngularJS Graphing Paper tool"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<angularjs-rails>, [">= 1.0.8"])
      s.add_runtime_dependency(%q<raphael-rails>, ["~> 2.1.2"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
    else
      s.add_dependency(%q<angularjs-rails>, [">= 1.0.8"])
      s.add_dependency(%q<raphael-rails>, ["~> 2.1.2"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<rcov>, [">= 0"])
    end
  else
    s.add_dependency(%q<angularjs-rails>, [">= 1.0.8"])
    s.add_dependency(%q<raphael-rails>, ["~> 2.1.2"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<rcov>, [">= 0"])
  end
end

