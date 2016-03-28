const React = require("react");

const AuthTokenField = require("../AuthTokenField")

const Form = React.createClass({

  render() {
    return (
      <form {...this.props}>
        <AuthTokenField />

        {this.props.children}
      </form>
    );
  },
});

module.exports = Form;
