# -*- coding: utf-8 -*-

require_relative 'dictionary'

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

def format_table(table)
  output = ["[table]\n"]
  translation = nil
  rows = table.lines.map {|l| l.chomp }
  rows.each do |row|
    row =~ /\A(\w+):(.*)\z/
    raise "C'est quoi, [[#{row}]]\?" unless $1 && $2
    formatter =
      case $1
      when "U" then formatter = UnicodeHieroglyphRowFormatter
      when "L" then formatter = TransliterationRowFormatter
      when "T" then translation = $2.strip; next
      else formatter = RowFormatter
      end
    output << formatter.new($2).to_bbcode + "\n"
  end
  if translation
    output << "[/table][i]#{translation}[/i]"
  else
    output << "[/table]"
  end
  output
end
