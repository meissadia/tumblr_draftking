def read_file(file_name)
  file = File.open(file_name, 'r')
  data = file.read
  file.close
  data
end

def generate_toc(filename)
  data = read_file(filename)
  base = 2
  indent = [0]
  last = base
  result = ''
  data.each_line do |line|
    next if line.include?('## Table of Contents')
    tabs = begin
             /^\+*\s*(?<hashes>\#{#{base},})/.match(line)[:hashes].length
           rescue
             next
           end
    indent.push(indent.last + 1) if tabs > last  # Add a level
    indent.pop                   if tabs < last  # Remove a level
    indent = [0]                 if tabs == base # Reset
    last   = tabs # Level check
    text   = line.delete('#').delete('+').strip
    link   = text.downcase.tr(' ', '-').delete(',')

    result += "\t" * indent.last + "+ [#{text}](##{link})\n"
  end
  result
end

file_name = 'readme/template.md'
old_text = read_file(file_name)
new_text = old_text.gsub(/{{TOC}}/, generate_toc(file_name))
File.open('README.md', 'w') { |file| file.write new_text }
