const React = require("react");

const LoadingSpinner = React.createClass({

  propTypes: { hidden: React.PropTypes.bool },

  getDefaultProps() { return { hidden: false }; },

  render() {
    return (
      <div
        className="LoadingSpinner"
        style={this.props.hidden ? { display: "none" } : {}}
      >
        Loading...
      </div>
    );
  },
});

module.exports = LoadingSpinner;
