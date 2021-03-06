# coding: utf-8


lib = File.expand_path("../lib", __FILE__)
unless $LOAD_PATH.include?(lib)
  $LOAD_PATH.unshift(lib) 
end

Gem::Specification.new do |spec|
  spec.name = "zenml-book"
  spec.version = "1.1.0"
  spec.authors = ["Ziphil"]
  spec.email = ["ziphil.shaleiras@gmail.com"]
  spec.licenses = ["MIT"]
  spec.homepage = "https://github.com/Ziphil/ZenithalBook"
  spec.summary = "Summary"
  spec.description = <<~end_string
    To be written.
  end_string
  spec.required_ruby_version = ">= 2.5"

  spec.files = Dir.glob("source/**/*.rb")
  spec.require_paths = ["source"]
end