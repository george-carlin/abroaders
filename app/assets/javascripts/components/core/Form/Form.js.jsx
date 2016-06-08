const React = require("react");
const _     = require("underscore");

const AuthTokenField = require("../AuthTokenField");
const HiddenFieldTag = require("../HiddenFieldTag");

const Form = React.createClass({
  propTypes: {
    method: React.PropTypes.string,
  },


  getDefaultProps() {
    return {
      method: "post"
    };
  },


  render() {
    var method, methodHiddenInput;
    const props = _.clone(this.props);

    if (_.includes(["get", "post"], props.method)) {
      method = props.method;
    } else {
      method = "post";
      methodHiddenInput = <HiddenFieldTag name="_method" value={props.method}/>;
    }

    delete props.method;

    return (
      <form
        acceptCharset="UTF-8"
        method={method}
        {...props}
      >
        <AuthTokenField />
        {methodHiddenInput}

        {this.props.children}
      </form>
    );
  },
});

module.exports = Form;
