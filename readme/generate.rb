# Read file contents
def read_file(file_name)
  file = File.open(file_name, 'r')
  data = file.read
  file.close
  data
end

# Build table of contents string from README template
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

# Inject Change information for latest version
def generate_clog(filename)
  data = read_file(filename)
  pattern = /(Version\s(?:\d\.?)*\n(?:.\n?)*)/
  pattern.match(data)[0]
end


# Table of Contents
file_name = 'readme/template.md'
new_text = read_file(file_name).gsub(/{{TOC}}/, generate_toc(file_name))

# Change log
file_name = 'CHANGELOG.md'
new_text = new_text.gsub(/{{CLOG}}/, generate_clog(file_name))

# Update file
File.open('README.md', 'w') { |file| file.write new_text }
