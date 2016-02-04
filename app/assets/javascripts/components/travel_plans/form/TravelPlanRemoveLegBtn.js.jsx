var TravelPlanRemoveLegBtn = React.createClass({

  propTypes: {
    hidden:   React.PropTypes.bool.isRequired,
    legIndex: React.PropTypes.number.isRequired,
    onClick:  React.PropTypes.func.isRequired,
  },

  render() {
    return (
      <button
        className="remove-travel-plan-leg-btn btn btn-default"
        data-leg-index={this.props.index}
        onClick={this.props.onClick}
        style={ this.props.hidden ? { display: "none" } : {} }
      >
        -
      </button>
    );
  }
});
