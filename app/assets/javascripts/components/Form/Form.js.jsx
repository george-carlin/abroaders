const React = require("react");
const _     = require("underscore");

const AuthTokenField = require("../AuthTokenField");
const HiddenFieldTag = require("../HiddenFieldTag");

const Form = React.createClass({
  render() {
    var methodInput, methodAttr;

    switch (this.props.method) {
      case "put":
        methodInput = (
          <HiddenFieldTag name="_method" value={this.props.method} />
        );
        methodAttr = "post";
        break;
      case "patch":
        methodInput = (
          <HiddenFieldTag name="_method" value={this.props.method} />
        );
        methodAttr = "post";
        break;
      default:
        methodInput = null;
        methodAttr = this.props.methodAttr;
        break;
    }

    var props = _.clone(this.props);
    delete props.method;

    return (
      <form
        acceptCharset="UTF-8"
        method={methodAttr}
        {...props}
      >
        <AuthTokenField />
        {methodInput}
        {this.props.children}
      </form>
    );
  },
});

module.exports = Form;
