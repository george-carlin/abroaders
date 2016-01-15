var CardRecommendationOptionsList = React.createClass({

  propTypes: {
    cards:        React.PropTypes.array.isRequired,
    hiddenBPs:    React.PropTypes.array.isRequired,
    hiddenBrands: React.PropTypes.array.isRequired
  },

  render() {
    var cards;

    cards = this.props.cards.filter(function (card) {
      return (
        !this.props.hiddenBrands.includes(card.brand) &&
          !this.props.hiddenBPs.includes(card.bp)
      )
    }.bind(this));

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
