var CardRecommendationFilters = React.createClass({

  propTypes: {
    updateBrandFilterCallback: React.PropTypes.func.isRequired
  },

  render() {
    return (
      <div className="form-inline">
        {["visa", "mastercard", "amex"].map(function (brand) {
          return (
            <CardRecommendationFilterBrandCheckbox
              key={brand}
              brand={brand}
              onChangeHandler={this.props.updateBrandFilterCallback}
            />
          )
        }.bind(this))}
      </div>
    )
  }

});
