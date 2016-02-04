var TravelPlanAddLegBtn = React.createClass({

  propTypes: {
    onClick: React.PropTypes.func.isRequired,
    hidden:  React.PropTypes.bool
  },

  render() {
    return (
      <button
        id="add-travel-plan-leg-btn"
        onClick={this.props.onClick}
        style={ this.props.hidden ? { display: "none" } : {} }
        className="btn btn-primary"
      >
        +
      </button>
    )
  }
});
