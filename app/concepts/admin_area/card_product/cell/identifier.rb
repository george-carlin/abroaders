module AdminArea
  module CardProduct
    module Cell
      # Takes a CardProduct, returns a short string that allows the admin to
      # quickly identify it.
      #
      # Format: AA-BBB-C.
      # A: bank code - An integer (see below)
      # B: product code - a 2-4 letter arbitrary code, set by the admin
      # C: network code - if network is unknown, then '?'. Else 'A', 'M', or 'V', for
      #                   Amex, MasterCard, or Visa respectively
      #
      class Identifier < Trailblazer::Cell
        def render
          [bank_code, code, network_code].join('-')
        end

        property :bank
        property :bp
        property :code
        property :network

        private

        # A 1-2 digit number which uniquely identifies both which bank the product belongs
        # to, and whether it is a business product or a personal one. this forms part of
        # the unique identifier for each product, which allows the admin to determine
        # these things about the product at a glance.
        #
        # The bank code is determined by the bank's id, which is always an odd number.
        # If this is a personal product, bank_number is equal to bank.id. If this is a
        # business product, bank_number is equal to bank.id + 1.
        #
        # (This numbering system is a legacy thing from before this app existed, when we
        # still doing everything through Fieldbook, Infusionsoft etc.)
        def bank_code
          '%.2d' % (bp == 'personal' ? bank.personal_code : bank.business_code)
        end

        def network_code
          network == 'unknown_network' ? '?' : network.upcase[0]
        end
      end
    end
  end
end
