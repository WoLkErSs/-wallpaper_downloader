require 'nokogiri'
require 'open-uri'
require 'fileutils'

if ARGV.length != 4
  puts 'Too few arguments'
  exit
end

regex = /\A(0[1-9]|1[0-2])\d{4}\z/
unless ARGV[1].match?(regex)
  puts 'Month must be like 102024'
  exit
end

month_d = ARGV[1][0..1]
year_d = ARGV[1][2..]
year = month_d == '12' ? year_d.to_i + 1 : year_d
next_month_i = month_d == '12' ? 1 : month_d.to_i + 1
month_s = Date::MONTHNAMES[next_month_i].downcase
url = "https://www.smashingmagazine.com/#{year_d}/#{month_d}/desktop-wallpaper-calendars-#{month_s}-#{year}/"

output_dir = "./#{ARGV[3]}-#{ARGV[1]}-wallpaper"
FileUtils.mkdir_p(output_dir)

html = URI.open(url).read
doc = Nokogiri::HTML(html)

start_node = doc.at_css('h2')
return unless start_node

start_node.xpath('following::p').each do |p|
  next unless p&.text&.downcase&.include?('flowers')
  ul = p.at_xpath('following-sibling::ul')
  next unless ul

  ul.css('li').each do |li|
    li.css('a').each do |a|
      src = a.attribute_nodes[0].value
      img_name = a.children[0].text
      next unless src && img_name

      file_name = File.join(output_dir, File.basename(src))
      File.write(file_name, URI.open(src).read)
    end
  end
end
