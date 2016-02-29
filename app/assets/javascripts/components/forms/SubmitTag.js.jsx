var React = require('react');

var SubmitTag = React.createClass({

  propTypes: {
    disabled: React.PropTypes.bool,
    value:    React.PropTypes.string,
  },

  getDefaultProps() {
    return {
      disabled: false,
      value:    "Save changes",
    };
  },

  render() {
    return (
      <input
        className="SubmitTag btn btn-primary"
        defaultValue={this.props.value}
        disabled={this.props.disabled}
        type="submit"
      />
    );
  },
});

module.exports = SubmitTag;
