var CardRecommendationForm = React.createClass({

  propTypes: {
    cards: React.PropTypes.object.isRequired
  },

  getInitialState() {
    return {
      hiddenBrands: [],
      hiddenBPs: []
    }
  },


  _updateFilters(filterType, value, e) {
    var hiddenValues = this.state[filterType]
    if (e.target.checked) {
      var index;
      if ( (index = hiddenValues.indexOf(value)) > -1) {
        hiddenValues.splice(index, 1)
      }
    } else {
      if (!hiddenValues.includes(value)) {
        hiddenValues.push(value)
      }
    }
    var newState = {}
    newState[filterType] = hiddenValues;
    this.setState(newState);
  },


  render() {
    return (
      <div>
        <CardRecommendationFilters updateFilterCallback={this._updateFilters} />
        <table id="admin_user_card_accounts_table" className="table table-striped">
          <thead>
            <tr>
              <th></th>
              <th>ID</th>
              <th>Name</th>
              <th>B/P</th>
              <th>Brand</th>
              <th>Type</th>
            </tr>
          </thead>
          <CardRecommendationOptionsList
            cards={this.props.cards}
            hiddenBrands={this.state.hiddenBrands}
            hiddenBPs={this.state.hiddenBPs}
          />
        </table>
      </div>
    )
  }

});
