# coding: utf-8


module Zenithal::Book

  VERSION = "1.0.1"
  VERSION_ARRAY = VERSION.split(/\./).map(&:to_i)

end


require 'fileutils'
require 'open3'
require 'rexml/document'

require_relative 'book/converter'