var CardRecommendationFilterBrandCheckbox = React.createClass({

  propTypes: {
    brand:           React.PropTypes.string.isRequired,
    onChangeHandler: React.PropTypes.func.isRequired
  },

  render() {
    return (
      <div className="checkbox">
        <label>
          <input
            type="checkbox"
            defaultChecked={true}
            onChange={
              this.props.onChangeHandler.bind(null, this.props.brand)
            }
          />
          &nbsp;{this.props.brand.capitalize()}&nbsp;
        </label>
      </div>
    )
  }

});
