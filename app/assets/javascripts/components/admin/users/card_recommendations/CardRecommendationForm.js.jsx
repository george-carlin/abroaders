var CardRecommendationForm = React.createClass({

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
    console.log(JSON.stringify(this.state));
    var cards = [
      {
        "id": 1,
        "identifier": "01-CSPV",
        "name": "Sapphire Preferred",
        "brand": "visa",
        "bp": "business",
        "type": "credit",
        "annual_fee_cents": 9500,
      },
      {
        "id": 2,
        "identifier": "01-BAV",
        "name": "British Airways",
        "brand": "visa",
        "bp": "personal",
        "type": "credit",
        "annual_fee_cents": 9500,
      },
      {
        "id": 3,
        "identifier": "01-SWPV",
        "name": "Southwest Premier",
        "brand": "mastercard",
        "bp": "business",
        "type": "credit",
        "annual_fee_cents": 9900,
      },
      {
        "id": 4,
        "identifier": "01-FRV",
        "name": "Freedom Rewards",
        "brand": "mastercard",
        "bp": "personal",
        "type": "credit",
        "annual_fee_cents": 0,
      }
    ]

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
            cards={cards}
            hiddenBrands={this.state.hiddenBrands}
            hiddenBPs={this.state.hiddenBPs}
          />
        </table>
      </div>
    )
  }

});
