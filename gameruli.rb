#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'ostruct'
require 'cgi'
require 'erb'
require 'open-uri'
require 'iconv'

cgi = CGI.new("html4")
puts cgi.header
#print "Content-type: text/html, encoding=UTF-8\r\n\r\n"

selected_category = cgi['category']

conv = Iconv.new('UTF-8', 'euc-kr')

$game_category_hash = {
  "online" => "PC 온라인",
  "xbox" => "XBOX360", 
  "ps" => "PlayStation 2/3", 
  "psp" => "PSP",
  "nin" => "Wii",
  "nds" => "Nintendo DS",
}

$game_titles = []

100.times do |idx|
  begin
    open("http://www.ruliweb.com/#{selected_category}/index#{idx > 0 ? idx + 1 : ""}.htm") do |f|
      conv.iconv(f.read) =~ /"conquest_top((.|\n)+?)"conquest_bottom"/
      $1.scan(/a href="(.+?)"><img src="(.+?)".+?alt="(.+?)"/).each do |entry|
        game_title = OpenStruct.new
        game_title.name = entry[2]
        game_title.category = selected_category
        game_title.link = entry[0]
        game_title.imgsrc = entry[1]
        $game_titles << game_title
      end
    end
  rescue
    #print Array($!).concat($@).join("<br>")
    break
  end
end

begin
  f = File.open("gameruli.html.erb", "r:UTF-8")
  data = f.read
  f.close
  tmpl = ERB.new(data)
  print tmpl.result(binding())
rescue
  print $!
end
