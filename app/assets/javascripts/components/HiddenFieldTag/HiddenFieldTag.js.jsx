const React = require("react");

const HiddenFieldTag = React.createClass({
  propTypes: {
    value: React.PropTypes.string.isRequired,
    name:  React.PropTypes.string.isRequired,
  },

  render() {
    return (
      <input
        type="hidden"
        {...this.props}
      />
    );
  },
});

module.exports = HiddenFieldTag;
