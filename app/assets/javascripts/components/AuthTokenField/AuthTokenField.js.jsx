const React = require('react');

const AuthTokenField = React.createClass({

  propTypes: {
    value: React.PropTypes.string
  },

  render() {
    return (
      <input
        name="authenticity_token"
        type="hidden"
        value={this.props.value}
      />
    );
  },
});

module.exports = AuthTokenField;
