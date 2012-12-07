#!/usr/bin/env ruby

require 'zip/zipfilesystem'
require 'fileutils'
require 'pathname'

abort('FLA file must be specified') if ARGV[0].nil?

fla_filename = ARGV[0]
path = Pathname.new(fla_filename).dirname
Dir.chdir(path)

dom_filename = 'DOMDocument.xml'
FileUtils.remove_file(dom_filename) if File.exists?(dom_filename)

Zip::ZipFile.open(fla_filename) do |flazip|
	flazip.extract(dom_filename, dom_filename)
end

system("open #{dom_filename}")
# FileUtils.remove_file(dom_filename)