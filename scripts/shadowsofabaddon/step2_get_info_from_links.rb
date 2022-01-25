# frozen_string_literal: true

require 'mechanize'
require 'nokogiri'
require 'byebug'
require 'json'

MOD = 'shadows_of_abaddon'
INFO_TXT_PATH = "public/#{MOD}_info.txt"
LINK_TXT_PATH = "public/#{MOD}_links.txt"

file = File.open(INFO_TXT_PATH, 'a')

agent = Mechanize.new

file = File.readlines(LINK_TXT_PATH).each do |line|
  next if File.foreach(INFO_TXT_PATH).grep(/#{line}/).any? || line.match(%r{/developers/})

  agent.get line.strip

  next if agent.page.parser.css('table.infobox tr td:contains("Type")').empty?

  doc = agent.page.parser

  image = doc.css('ul li a.image').last&.at_css('img') || doc.at_css('a.image img')

  file.write({
    name: doc.at_css('meta[property="og:title"]')&.attr('content'),
    types: doc.at_css('table.infobox tr td:contains("Type")').next_element.text.split(' – '),
    description: doc.at_css('meta[property="og:description"]')&.attr('content'),
    link: doc.at_css('meta[property="og:url"]')&.attr('content'),
    image_link: image['src'],
    mod: MOD
  }.to_json.to_s + "\n")
rescue StandardError => e
  byebug
  puts e
end