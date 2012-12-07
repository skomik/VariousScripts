#!/usr/bin/env ruby

abort('FLA file must be specified') if ARGV[0].nil?

fla_file = ARGV[0]
folder_name = File.basename(fla_file, File.extname(fla_file))

Dir.chdir(File.dirname(fla_file))
system("ditto -xk \"#{File.basename(fla_file)}\" \"#{folder_name}\"")