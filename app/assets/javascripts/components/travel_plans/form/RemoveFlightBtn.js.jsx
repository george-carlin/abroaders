var RemoveFlightBtn = React.createClass({

  propTypes: {
    hidden:   React.PropTypes.bool.isRequired,
    flightIndex: React.PropTypes.number.isRequired,
    onClick:  React.PropTypes.func.isRequired,
  },

  render() {
    return (
      <button
        className="remove-flight-btn btn btn-default"
        data-flight-index={this.props.index}
        onClick={this.props.onClick}
        style={ this.props.hidden ? { display: "none" } : {} }
      >
        -
      </button>
    );
  }
});
