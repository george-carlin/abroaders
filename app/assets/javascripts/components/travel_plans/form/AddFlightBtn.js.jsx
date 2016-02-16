var AddFlightBtn = React.createClass({

  propTypes: {
    onClick:  React.PropTypes.func.isRequired,
    hidden:   React.PropTypes.bool,
    disabled: React.PropTypes.bool,
  },

  render() {
    return (
      <button
        id="add-flight-btn"
        onClick={this.props.onClick}
        style={ this.props.hidden ? { display: "none" } : {} }
        className="AddFlightBtn btn btn-primary"
        disabled={this.props.disabled}
      >
        + Add Flight
      </button>
    )
  }
});
