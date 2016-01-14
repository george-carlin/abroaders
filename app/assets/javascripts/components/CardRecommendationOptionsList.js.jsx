var CardRecommendationOptionsList = React.createClass({

  propTypes: {
    cards:   React.PropTypes.array.isRequired,
    filters: React.PropTypes.object.isRequired
  },

  render() {
    var filters = this.props.filters,

        cards = this.props.cards.filter(function (card) {
          // Filter by brands
          return (
            filters.brands.includes(card.brand)
            // && other filters, once I add them 
          )
        });

    return (
      <tbody>
        {cards.map(function (card) {
          return (
            <CardRecommendationOption key={card.id} card={card} />
          )
        })}
      </tbody>
    )
  }
});
