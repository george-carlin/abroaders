module AdminArea::CardRecommendations::Cell
  # Takes an array of card recommendations and displays them in a <table>.  Can
  # take an empty array, in which case the table will have no rows.
  #
  # @!method self.call(recs, options = {})
  #   @param recs [Collection<Card>] array of card recommendations
  class Table < Abroaders::Cell::Base
    option :html_id, optional: true
    option :edit_redirection, optional: true
    # When this is true each row include an extra column with a link to the
    # page for the offer's person
    option :with_person_column, default: false

    def show
      <<-HTML
        <table
          class='table table-striped tablesorter'
          id=#{html_id}
        >
          <thead>
            #{'<th>Person</th>' if with_person_column}
            <th>Product</th>
            <th>Offer</th>
            <th>Status</th>
            <th>Rec'ed</th>
            <th>Seen</th>
            <th>Clicked</th>
            <th>Applied</th>
            <th>Declined</th>
            <th></th>
          </thead>
          <tbody>
            #{rows}
          </tbody>
        </table>
      HTML
    end

    private

    def rows
      cell(Row, options.merge(collection: model))
    end

    class Row < Abroaders::Cell::Base
      option :edit_redirection, optional: true
      option :with_person_column, default: false

      include Escaped

      # @param recommendation [Card] must be a recommendation
      def initialize(rec, options = {})
        super(CardRecommendation.new(rec), options)
      end

      property :id
      property :applied_on
      property :card_product
      property :clicked_at
      property :decline_reason
      property :declined?
      property :declined_at
      property :offer
      property :person
      property :recommended_at
      property :seen_at
      property :status
      property :unresolved?

      private

      delegate :bp, to: :card_product, prefix: true

      %i[
        recommended_at seen_at clicked_at denied_at declined_at applied_on
      ].each do |date_attr|
        define_method date_attr do
          super()&.strftime('%D') || '-' # 12/01/2015
        end
      end

      # If the card was opened/closed after being recommended by an admin,
      # we know the exact date it was opened closed. If they added the card
      # themselves (e.g. when onboarding), they only provide the month
      # and year, and we save the date as the 1st of thet month.  So if the
      # card was added as a recommendation, show the the full date, otherwise
      # show e.g.  "Jan 2016". If the date is blank, show '-'
      #
      # TODO rethink how we know whether a card was added in the survey
      %i[closed_on opened_on].each do |date_attr|
        define_method date_attr do
          # if model.recommended_at.nil? # if card is not a recommendation
          # super()&.strftime('%b %Y') || '-' # Dec 2015
          # else
          super()&.strftime('%D') || '-' # 12/01/2015
          # end
        end
      end

      def card_product_name
        cell(CardProduct::Cell::FullName, card_product, with_bank: true)
      end

      def decline_reason_tooltip
        return '' unless model.declined?
        link_to('#', 'data-toggle': 'tooltip', title: decline_reason) do
          fa_icon('question')
        end
      end

      def link_to_delete
        link_to(
          'Del',
          admin_card_recommendation_path(model),
          data: {
            confirm: 'Are you sure you want to delete this recommendation?',
            method: :delete,
          },
        )
      end

      def link_to_edit
        url = edit_admin_card_recommendation_path(
          model,
          redirect_to: edit_redirection,
        )
        link_to('Edit', url)
      end

      def link_to_offer
        link_to(
          offer_identifier,
          admin_offer_path(offer),
          class: ('unresolved-dead-offer' if offer.dead? && unresolved?),
        )
      end

      def link_to_person
        link_to escape!(person.first_name), admin_person_path(person)
      end

      def offer_identifier
        cell(AdminArea::Offers::Cell::Identifier, offer, with_partner: true)
      end

      def status
        Inflecto.humanize(super)
      end

      def tr_tag(&block)
        content_tag(
          :tr,
          id: "card_recommendation_#{id}",
          class: 'card_recommendation',
          'data-bp':       card_product.bp,
          'data-bank':     card_product.bank_id,
          'data-currency': card_product.currency_id,
          &block
        )
      end
    end
  end
end
