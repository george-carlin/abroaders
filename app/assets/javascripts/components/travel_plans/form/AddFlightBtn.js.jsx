var React = require('react');

var AddFlightBtn = React.createClass({

  propTypes: {
    onClick: React.PropTypes.func.isRequired,
    // 'disabled' means it's visible but disabled.
    status:  React.PropTypes.oneOf(["active", "disabled", "hidden"]),
  },

  render() {
    // Disable the button when it's hidden, to prevent it accidentally being
    // triggered by e.g. enter presses elsewhere in the form.
    return (
      <button
        className="AddFlightBtn btn btn-primary"
        disabled={this.props.status !== "active"}
        id="add-flight-btn"
        onClick={this.props.onClick}
        style={this.props.status === "hidden" ? { display: "none" } : {}}
      >
        + Add Flight
      </button>
    )
  },
});

module.exports = AddFlightBtn;
