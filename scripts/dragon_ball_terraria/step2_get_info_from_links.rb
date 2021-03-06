# frozen_string_literal: true

require 'mechanize'
require 'nokogiri'
require 'json'

MOD = 'dragon_ball_terraria'
INFO_TXT_PATH = "public/jsonl/#{MOD}_info.jsonl"
LINK_TXT_PATH = "public/jsonl/#{MOD}_links.jsonl"

file = File.open(INFO_TXT_PATH, 'a')

agent = Mechanize.new

file = File.readlines(LINK_TXT_PATH).each do |line|
  next if File.foreach(INFO_TXT_PATH).grep(/#{line}/).any?

  agent.get line.strip

  next if agent.page.parser.css('table.stat tr th:contains("Type")').empty?

  doc = agent.page.parser

  image = doc.css('ul li a.image').last&.at_css('img') || doc.at_css('a.image img') || doc.at_css('div.images ul li img')

  file.write({
    name: doc.at_css('meta[property="og:title"]')['content'],
    types: doc.at_css('table.stat tr th:contains("Type")').next_element.text.split(' – '),
    description: doc.at_css('meta[property="og:description"]')['content'],
    link: doc.at_css('meta[property="og:url"]')['content'],
    image_link: image['src'],
    mod: MOD
  }.to_json.to_s + "\n")
end
