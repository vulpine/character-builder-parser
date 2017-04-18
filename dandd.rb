#!/usr/bin/ruby

require 'nokogiri'

def get_file_xml(filename)
  xml = File.open(filename, 'rb') { |f| Nokogiri::XML(f) }
  xml
end

def get_race_names(xml)
  races = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if ruleselement.attr('type') == "Race"
      races << ruleselement.attr('name')
    end
  end
  races
end

# Fix this eventually, but for now just grab the first argument.
filename = ARGV[0]

xml = get_file_xml(filename)

races = get_race_names(xml)
puts races.join(', ')
