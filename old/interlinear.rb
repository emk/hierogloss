# -*- coding: utf-8 -*-

require 'cgi'
require_relative 'dictionary'

# http://stackoverflow.com/questions/4800337/split-array-into-sub-arrays-based-on-value
module Enumerable
  def split_by
    result = [a=[]]
    each{ |o| yield(o) ? (result << a=[]) : (a << o) }
    result.pop if a.empty?
    result
  end
end

class RowFormatter
  def initialize(row_text)
    @columns = row_text.split(/\|/).map {|c| c.strip }
  end

  def to_bbcode
    cols = @columns.map {|c| "[td]#{column_to_bbcode(c)}[/td]" }
    "[tr]#{cols.join(" ")}[/tr]"
  end

  def column_to_bbcode(col)
    col
  end

  def search_link(query, text)
    search_url = "http://www.hierogl.ch/hiero/Sp%C3%A9cial:Recherche"
    escaped_query = CGI.escape(query)
    "[url=#{search_url}?search=#{escaped_query}&go=Lire]#{text}[/url]"
  end
end

class UnicodeHieroglyphRowFormatter < RowFormatter
  def column_to_bbcode(col)
    linked = col.chars.map do |c|
      gardiner = Dictionary.gardiner(c)
      if !gardiner.nil?
        search_link("Signe:#{gardiner}", c)
      else
        c
      end
    end.join
    "[size=24]#{linked}[/size]"
  end
end

class TransliterationRowFormatter < RowFormatter
  JR_TRANSLITERATION = {
    "A" => "ꜣ",
    "i" => "j",
    "a" => "ꜥ",
    "H" => "ḥ",
    "x" => "ḫ",
    "X" => "ẖ",
    "S" => "š",
    "q" => "ḳ",
    "K" => "ḳ",
    "T" => "ṯ",
    "D" => "ḏ"
  }

  def column_to_bbcode(col)
    fancy = self.class.fancy(col)
    search_link(Dictionary.headword(col), fancy)
  end

  def self.fancy(tl)
    tl.chars.map {|c| JR_TRANSLITERATION[c] || c }.join
  end
end

puts "[url=http://users.teilar.gr/~g1951d/Gardiner.ttf][i](Télécharger une police hiéroglyphique)[/i][/url]"

def format_table(table)
  puts "[table]"
  translation = nil
  table.each do |row|
    row =~ /\A(\w+):(.*)\z/
    raise "C'est quoi, [[#{row}]]\?" unless $1 && $2
    formatter =
      case $1
      when "U" then formatter = UnicodeHieroglyphRowFormatter
      when "L" then formatter = TransliterationRowFormatter
      when "T" then translation = $2.strip; next
      else formatter = RowFormatter
      end
    puts formatter.new($2).to_bbcode
  end
  if translation
    puts "[/table][i]#{translation}[/i]"
  else
    puts "[/table]"
  end
end

def format_remarks(remarks)
  text = remarks.map {|row| row.gsub(/\A>\s*/, '') }.join(' ')
  formatted = text.gsub(/`([^`]*)`/) do
    "[i]#{TransliterationRowFormatter.fancy($1)}[/i]"
  end
  puts formatted
end

STDIN.lines.split_by {|l| l.chomp!; l =~ /^\S*$/ }.each do |table|
  if table[0] =~ /\A>/
    format_remarks(table)
  else
    format_table(table)
  end
  puts
end
