#!/usr/bin/env ruby -wKU


require 'open-uri'
require 'nokogiri'

urls  = [
  "https://users.cs.jmu.edu/foxcj/Public/ConciseNotesRuby/Containers/",
  "https://users.cs.jmu.edu/foxcj/Public/ConciseNotesRuby/Etc/",
  "https://users.cs.jmu.edu/foxcj/Public/ConciseNotesRuby/Graphs/",
]



def download(url)
  `mkdir -p #{File.dirname(local_filename(url))}`
  `curl #{full_url(url)} > #{local_filename(url)}` unless File.exists?(local_filename(url))
end

def local_filename(url)
  #/foxcj/Public/ConciseNotesRuby/Containers/ArrayDequeue.rb.txt
  url.gsub("/foxcj/Public/ConciseNotesRuby/", "").gsub(".txt", "")
end

def full_url(url)
  "https://users.cs.jmu.edu#{url}"
end


all_links = []
urls.each do |url|
  html = open(url).read
  doc = Nokogiri::HTML(html)
  links = doc.css("a")
  all_links += links.map{|x| x.attributes['href'].value}
end
clean_links = all_links.select{|x| x != "/foxcj/Public/ConciseNotesRuby/"}
#puts clean_links.join("\n")

clean_links.each do |link|
  download(link)
end
