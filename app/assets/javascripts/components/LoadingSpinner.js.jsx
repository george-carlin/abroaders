var React = require('react');

var LoadingSpinner = React.createClass({

  propTypes: { hidden: React.PropTypes.bool },

  getDefaultProps() { return { hidden: false } },

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
})

module.exports = LoadingSpinner
