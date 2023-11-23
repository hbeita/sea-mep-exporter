# frozen_string_literal: true
require 'unicode_utils'
module Utils
  def normalize_string(string:)
    return if string.nil?

    replaced_accented_characters = UnicodeUtils.nfkd(string).gsub(/[^\p{ASCII}]/, '')

    replaced_accented_characters.gsub(/[,']/, '')

    # trim beginning and ending spaces
    replaced_accented_characters.strip

    # just one space between words
    replaced_accented_characters.gsub(/\s+/, ' ')

    # split into words and remove the last word if index is greater than 3
    words = replaced_accented_characters.split(' ')
    words.pop if words.length > 3
    words.join(' ')
  end
end