const React = require("react");
const _     = require("underscore");

const AuthTokenField = require("./AuthTokenField");
const HiddenFieldTag = require("./HiddenFieldTag");

const Form = (_props) => {
  let method, methodHiddenInput;
  const props = Object.assign({}, _props);

  if (!["get", "post"].includes(props.method)) {
    method = "post";
    // A Railsy tag for faking 'delete', 'put' etc HTTP requests:
    methodHiddenInput = <HiddenFieldTag name="_method" value={props.method} />;
  } else {
    method = props.method;
  }

  return (
    <form acceptCharset="UTF-8" {...props} method={method} >
      <AuthTokenField />
      {methodHiddenInput}

      {props.children}
    </form>
  );
};

Form.propTypes = {
  method: React.PropTypes.string,
};

Form.defaultProps = {
  method: "post",
};

module.exports = Form;
