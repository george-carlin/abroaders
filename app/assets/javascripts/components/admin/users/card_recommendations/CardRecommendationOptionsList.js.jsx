var CardRecommendationOptionsList = React.createClass({

  propTypes: {
    cards:        React.PropTypes.object.isRequired,
    hiddenBPs:    React.PropTypes.array.isRequired,
    hiddenBrands: React.PropTypes.array.isRequired
  },

  render() {
    var cards;

    cards = this.props.cards.data.filter(function (card) {
      // String.prototype.includes would be better than indexOf but it's an
      // ES6 feature and doesn't work in PhantomJS (i.e. in the tests).  TODO
      // figure out how to make the transpiler work in test as well as dev
      // modes.
      return (
        this.props.hiddenBrands.indexOf(card.attributes.brand) < 0 &&
          this.props.hiddenBPs.indexOf(card.attributes.bp) < 0
      )
    }.bind(this));

    var dummyFunc = function () { };

    return (
      <tbody>
        {cards.map(function (card) {
          return (
            <CardRecommendationOption
              key={card.id}
              card={card}
              clickHandler={dummyFunc}
            />
          )
        })}
      </tbody>
    )
  }
});
