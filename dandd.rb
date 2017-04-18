#!/usr/bin/ruby

require 'nokogiri'
require 'optparse'

def get_file_xml(filename)
  xml = File.open(filename, 'rb') { |f| Nokogiri::XML(f) }
  xml
end

def get_objects_of_type(xml, type)
  types = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if ruleselement.attr('type') == type
      types << ruleselement.attr('name')
    end
  end
  types
end

def get_all_types(xml)
  types = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if !types.include? ruleselement.attr('type')
      types << ruleselement.attr('type')
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

  opts.on("-t", "--types", "List all types available in the input file.") do |t|
    options[:types] = t
  end

  opts.on("-l", "--list TYPE", "List all objects of TYPE in the input file.") do |l|
    options[:list] = l
  end

  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit
  end

end.parse!


xml = get_file_xml(options[:input_file])

# I decided not to make these mutually exclusive.
# If you want to list all types and then all objects of a particular one, go for it.
if options[:types]
  types = get_all_types(xml)
  puts "This file contains the following types of object:"
  puts types.join(', ')
end

if options[:list]
  desired_type = options[:list]
  types = get_objects_of_type(xml, desired_type)
  puts "All #{desired_type} objects found:"
  puts types.join(', ')
end
