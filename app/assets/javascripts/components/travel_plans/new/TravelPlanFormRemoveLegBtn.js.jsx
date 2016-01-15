var TravelPlanFormRemoveLegBtn = React.createClass({

  propTypes: {
    onClickCallback: React.PropTypes.func.isRequired,
    hidden:          React.PropTypes.bool
  },

  render() {
    if (this.props.hidden) {
      return <div></div>
    } else {
      return (
        <button onClick={this.props.onClickCallback}
                className="remove-travel-plan-leg-btn btn btn-default">-</button>
      )
    }
  }
});
