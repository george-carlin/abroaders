var CardRecommendationForm = React.createClass({

  getInitialState() {
    return {
      filters: {
        brands: ["visa", "mastercard", "amex"]
      }
    }
  },

  _updateBrandFilters(brand, e) {
    var filter = this.state.filters.brands
    if (e.target.checked) {
      if (!filter.includes(brand)) {
        filter.push(brand)
        this.setState({filters: { brands: filter }});
      }
    } else {
      var index;
      if ( (index = filter.indexOf(brand)) > -1) {
        filter.splice(index, 1)
        this.setState({filters: { brands: filter }});
      }
    }
  },

  render() {
    var cards = [
      {
        "id": 1,
        "identifier": "01-CSPV",
        "name": "Sapphire Preferred",
        "brand": "visa",
        "bp": "personal",
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
        "bp": "personal",
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
        <CardRecommendationFilters
          updateBrandFilterCallback={this._updateBrandFilters}
        />
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
            filters={this.state.filters} />
        </table>
      </div>
    )
  }

});
