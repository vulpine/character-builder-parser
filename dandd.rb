#!/usr/bin/ruby

require 'nokogiri'
require 'optparse'

def get_file_xml(filename)
  xml = File.open(filename, 'rb') { |f| Nokogiri::XML(f) }
  xml
end

def generate_new_partfile()
  new_partfile = Nokogiri::XML::Document.new('1.0')
  new_partfile.encoding = 'utf-8'
  d20_node = Nokogiri::XML::Node.new('D20Rules', new_partfile)
  d20_node.set_attribute('game-system', "D&D4E")
  new_partfile.add_child(d20_node)
  new_partfile
end

# Gets all RulesElements of the specified type. For example, Fighter, Cleric, Rogue.
def get_elements_of_type(xml, type)
  types = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if ruleselement.attr('type') == type
      types << ruleselement.attr('name')
    end
  end
  types
end

# Gets all types of RulesElement in the XML. For example, Class, Race, Power.
def get_all_types(xml)
  types = []
  xml.xpath('//RulesElement').each do |ruleselement|
    if !types.include? ruleselement.attr('type')
      types << ruleselement.attr('type')
    end
  end
  types
end

# Copy an element to another.
def copy_element(xml, element_type, source, target)
  # First, does this class even exist in this file?
  elements = get_elements_of_type(xml, element_type)
  unless elements.include?(source)
    puts "I can't find #{element_type} #{source} in this file."
    return nil
  end

  puts "DEBUG: Found #{element_type} #{source}."
  target_xml = generate_new_partfile()
  xml.xpath('//RulesElement').each do |ruleselement|
    if ruleselement.attr('type') == element_type
      if ruleselement.attr('name') == source
        # We just duplicate the first one we find.
        new_element = ruleselement.dup

        new_element.set_attribute('name', target)

        # Example internal ID for Fighter Class is ID_FMP_CLASS_793. These must be unique.
        old_internal_id = ruleselement.attr('internal-id').rpartition('_')
        internal_id_base = old_internal_id.first
        internal_id_number = old_internal_id.last

        puts "Please provide a unique internal ID number."
        puts "(The internal ID number for #{source} is #{internal_id_number})"
        internal_id_number = gets.chomp
        new_element.set_attribute('internal-id', internal_id_base + "_" + internal_id_number)

        target_xml.root.add_child(new_element)
      end
    end
  end
  target_xml
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

  opts.on("-l", "--list TYPE", "List all elements of TYPE in the input file.") do |l|
    options[:list] = l
  end

  opts.on("-c", "--copy-class CLASS", "Copy CLASS to a new class.") do |c|
    options[:copyclass] = c
  end

  opts.on("-r", "--copy-race RACE", "Copy RACE to a new race.") do |r|
    options[:copyrace] = r
  end

  opts.on("-d", "--destination NAME", "Destination to copy to.") do |d|
    options[:destination] = d
  end

  opts.on('-h', '--help', 'Display this screen.') do
    puts opts
    exit
  end

end.parse!

if options[:input_file]
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
    types = get_elements_of_type(xml, desired_type)
    puts "All #{desired_type} objects found:"
    puts types.join(', ')
  end

  if options[:copyclass]
    source = options[:copyclass]
    if options[:destination]
      destination = options[:destination]
    else
      puts "What shall I copy #{source} to?"
      destination = gets.chomp.capitalize
    end
    puts "DEBUG: Copying #{source} to #{destination}"
    puts copy_element(xml, 'Class', source, destination)
  end
end
