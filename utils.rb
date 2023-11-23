# frozen_string_literal: true
require 'unicode_utils'
module Utils
  def normalize_string(string:)
    return if string.nil?

    clean_accents_text = UnicodeUtils.nfkd(string).gsub(/[^\p{ASCII}]/, '')

    clean_accents_text.gsub(/[,']/, '')

    # trim beginning and ending spaces
    clean_accents_text.strip

    # just one space between words
    clean_accents_text.gsub(/\s+/, ' ')

    # split into words and remove the last word if index is greater than 3 # Arbitrary due to super bad Excel format
    words = clean_accents_text.split(' ')
    words.pop if words.length > 3
    words.join(' ')
  end
end