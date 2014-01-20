# -*- coding: utf-8 -*-


require 'hierogloss/dictionary'

module Hierogloss
  #:nodoc:
  class Row
    attr_reader :raw_cells

    def initialize(row_text)
      @raw_cells = row_text.split(/\|/).map {|c| c.strip }
    end

    def span?
      false
    end

    def attributes
      attrs = {}
      attrs['class'] = class_attr if class_attr
      attrs
    end
  
    def class_attr
      nil
    end

    def to_kramdown
      attrs = attributes
      tr = Kramdown::Element.new(:tr, nil, attrs)
      raw_cells.each do |c|
        td = Kramdown::Element.new(:td, nil, attrs)
        children = cell_to_kramdown(c)
        if children.kind_of?(Array)
          td.children.concat(children)
        else
          td.children << children
        end
        tr.children << td
      end
      tr
    end

    def cell_to_kramdown(cell)
      Kramdown::Element.new(:text, cell)
    end

    def search_link(query, text)
      base_url = "http://www.hierogl.ch/hiero/Sp%C3%A9cial:Recherche"
      escaped_query = CGI.escape(query)
      url = "#{base_url}?search=#{escaped_query}&go=Lire"
      
      link = Kramdown::Element.new(:a, nil, {'href' => url})
      link.children << Kramdown::Element.new(:text, text)
      link
    end
  end

  #:nodoc:
  class UnicodeHieroglyphRow < Row
    def class_attr
      'hieroglyphs'
    end

    def cell_to_kramdown(cell)
      cell.chars.map do |c|
        gardiner = Dictionary.gardiner(c)
        if !gardiner.nil?
          search_link("Signe:#{gardiner}", c)
        else
          Kramdown::Element.new(:text, c)
        end
      end
    end
  end

  #:nodoc:
  class TransliterationRow < Row
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

    def self.fancy(tl)
      tl.chars.map {|c| JR_TRANSLITERATION[c] || c }.join
    end

    def class_attr
      'transliteration'
    end

    def cell_to_kramdown(cell)
      fancy = self.class.fancy(cell)
      search_link(Dictionary.headword(cell), fancy)
    end
  end

  #:nodoc:
  class TranslationRow
    attr_reader :text

    def initialize(row_text)
      @text = row_text.strip
    end

    def span?
      true
    end

    def to_kramdown
      em = Kramdown::Element.new(:em)    
      em.children << Kramdown::Element.new(:text, text)
      em
    end
  end

  #:nodoc:
  class Gloss
    attr_reader :rows

    def initialize(text)
      @rows = text.lines.map {|l| l.chomp }.map do |row|
        row =~ /\A(\w+):(.*)\z/
        raise "C'est quoi, [[#{row}]]\?" unless $1 && $2
        type =
          case $1
          when "U" then UnicodeHieroglyphRow
          when "L" then TransliterationRow
          when "T" then TranslationRow
          else Row
          end
        type.new($2)
      end
    end

    def to_kramdown
      result = []
      # Neither Kramdown nor BBCode support rowspans, so we'll just cheat
      # for now.
      rows.chunk {|r| r.span? }.each do |spans, rows|
        if spans
          rows.each do |r|
            p = Kramdown::Element.new(:p, nil, 'class' => 'gloss')
            p.children << r.to_kramdown
            result << p
          end
        else
          table = Kramdown::Element.new(:table, nil, { 'class' => 'gloss' },
                                        alignment: [])
          tbody = Kramdown::Element.new(:tbody)
          table.children << tbody
          rows.each {|r| tbody.children << r.to_kramdown }
          result << table
        end
      end
      result
    end
  end
end