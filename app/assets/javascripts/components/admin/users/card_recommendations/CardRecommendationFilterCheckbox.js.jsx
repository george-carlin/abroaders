var CardRecommendationFilterCheckbox = React.createClass({

  propTypes: {
    filterType: React.PropTypes.string.isRequired,
    value:      React.PropTypes.string.isRequired,
    onChangeHandler: React.PropTypes.func.isRequired
  },

  render() {
    var onChangeHandler = this.props.onChangeHandler.bind(
      null,
      this.props.filterType,
      this.props.value
    )

    return (
      <div className="checkbox">
        <label>
          <input
            type="checkbox"
            defaultChecked={true}
            onChange={onChangeHandler}
          />
          &nbsp;{this.props.value.capitalize()}&nbsp;
        </label>
      </div>
    )
  }

});
