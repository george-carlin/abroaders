var CardRecommendationFilters = React.createClass({

  propTypes: {
    updateFilterCallback: React.PropTypes.func.isRequired,
  },

  render() {
    return (
      <div className="form-inline">
        {["visa", "mastercard", "amex"].map(function (brand) {
          return (
            <CardRecommendationFilterCheckbox
              key={"brand-" + brand}
              filterType="hiddenBrands"
              value={brand}
              onChangeHandler={this.props.updateFilterCallback}
            />
          )
        }.bind(this))}

        &nbsp; | &nbsp;&nbsp;

        {["business", "personal"].map(function (bp) {
          return (
            <CardRecommendationFilterCheckbox
              key={"bp-" + bp}
              filterType="hiddenBPs"
              value={bp}
              onChangeHandler={this.props.updateFilterCallback}
            />
          )
        }.bind(this))}
      </div>
    )
  }

});
