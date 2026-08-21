# Front matter `totalPrize` is free text ("60 Bin TL'dir", "5.000 USD + 50 Bin
# TL'dir.", "Bisiklet", "Altın", "2 Bin 500 TL'lik Hediye Çeki", ...) — money,
# other currencies, and non-monetary prizes are all mixed in. This filter
# extracts a plain TRY integer only for the unambiguous, TL-only, cash-amount
# case; anything else (other currencies, mixed/non-cash prizes, unparseable
# formats) returns nil so callers can omit schema.org `offers` rather than
# publish a wrong or invented number.
module Jekyll
  module PrizeAmountParserFilter
    MULTIPLIERS = { "bin" => 1_000, "milyon" => 1_000_000 }.freeze
    TL_WORD = /\A[Tt][Ll](['’](dir|dır|dur|dür|lik|lık))?\.?\z/.freeze
    NUMBER_WORD = /\A\d[\d.]*\z/.freeze

    def prize_amount_try(input)
      return nil if input.nil? || input.to_s.strip.empty?

      words = input.to_s.strip.split(/\s+/)
      tl_index = words.index { |w| w =~ TL_WORD }
      return nil if tl_index.nil?

      # Anything after the TL word must be decorative (emoji/punctuation) —
      # real trailing text means it's a mixed or non-cash prize.
      trailing = words[(tl_index + 1)..]
      return nil if trailing.any? { |w| w =~ /[\p{L}\p{N}]/ }

      total = 0
      pending = nil

      words[0...tl_index].each do |word|
        key = word.downcase
        if word =~ NUMBER_WORD
          parsed = word.delete(".").to_i
          if pending.nil?
            pending = parsed
          elsif parsed.to_s.length == 3
            # space used as a thousands separator, e.g. "19 500" => 19500
            pending = pending * 1000 + parsed
          else
            return nil
          end
        elsif MULTIPLIERS.key?(key)
          total += (pending || 1) * MULTIPLIERS[key]
          pending = nil
        else
          return nil
        end
      end

      total += pending if pending
      total.positive? ? total : nil
    end
  end
end

Liquid::Template.register_filter(Jekyll::PrizeAmountParserFilter)
