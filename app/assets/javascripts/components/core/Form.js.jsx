import React, { PropTypes } from "react";
const _     = require("underscore");

const AuthTokenField = require("./AuthTokenField");
const HiddenFieldTag = require("./HiddenFieldTag");

const Form = (_props) => {
  let methodHiddenInput;
  const props = Object.assign({}, _props);

  if (!["get", "post"].includes(props.method)) {
    props.method = "post";
    // A Railsy tag for faking 'delete', 'put' etc HTTP requests:
    methodHiddenInput = <HiddenFieldTag name="_method" value={props.method} />;
  }

  return (
    <form acceptCharset="UTF-8" {...props} >
      <AuthTokenField />
      {methodHiddenInput}

      {props.children}
    </form>
  );
};

Form.propTypes = {
  method: PropTypes.string,
};

Form.defaultProps = {
  method: "post",
};

module.exports = Form;
