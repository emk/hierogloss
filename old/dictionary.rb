# -*- coding: utf-8 -*-

module Dictionary
  GARDINER = {}
  File.open("Unicode-MdC-Mapping-v1.utf8", "r:bom|utf-8") do |f|
    f.each_line do |l|
      l.chomp!
      sign, hex, codes, remarks = l.split(/\t/, 4)
      for code in codes.split(/ /)
        next unless code =~ /\A[A-Z][0-9]+\z/
        GARDINER[sign] = code
      end
    end
  end
  "𓄿𓇋𓏭𓂝𓅱𓏲𓃀𓊪𓆑𓅓𓈖𓂋𓉔𓎛𓐍𓄡𓊃𓋴𓈙𓈎𓎡𓎼𓏏𓍿𓂧𓆓".each_char do |c|
    GARDINER.delete(c)
  end


  # Try to kick things into shape for hierogl.ch.
  def self.headword(word)
    hw = word
    hw.gsub!(/[()]/, '')
    hw.sub!(/=.*\z/, '')
    hw.sub!(/\.w?t\z/, 't')
    hw.sub!(/\..*\z/, '')
    hw
  end

  # Given a Unicode hieroglyph, get the corresponding Gardiner sign.
  def self.gardiner(sign)
    GARDINER[sign]
  end
end
