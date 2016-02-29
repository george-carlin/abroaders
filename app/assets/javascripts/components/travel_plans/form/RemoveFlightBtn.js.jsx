var React = require('react');

var RemoveFlightBtn = React.createClass({

  propTypes: {
    flightIndex: React.PropTypes.number.isRequired,
    hidden:   React.PropTypes.bool.isRequired,
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
  },
});


module.exports = RemoveFlightBtn;
