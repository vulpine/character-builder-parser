#!/usr/bin/ruby

require 'nokogiri'
require 'optparse'

def get_file_xml(filename)
  xml = File.open(filename, 'rb') { |f| Nokogiri::XML(f) }
  xml
end

def get_types(xml, type)
  types = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if ruleselement.attr('type') == type.capitalize
      types << ruleselement.attr('name')
    end
  end
  types
end

options = {}
OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on("-i", "--input-file FILENAME", "File to read data from.") do |i|
    options[:input_file] = i
  end

  opts.on("-l", "--list TYPE", "List all TYPEs in the input file.") do |l|
    options[:list] = l
  end
end.parse!


xml = get_file_xml(options[:input_file])

if options[:list]
  types = get_types(xml, options[:list])
  puts types.join(', ')
end
