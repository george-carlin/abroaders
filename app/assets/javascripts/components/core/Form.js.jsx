import React, { PropTypes } from "react";

import AuthTokenField from "./AuthTokenField";

const Form = (_props) => {
  let method, methodHiddenInput;
  const props = Object.assign({}, _props);

  if (!["get", "post"].includes(props.method)) {
    method = "post";
    // A Railsy tag for faking 'delete', 'put' etc HTTP requests:
    methodHiddenInput = (
      <input
        name="_method"
        type="hidden"
        value={props.method}
      />
    );
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
  method: PropTypes.string,
};

Form.defaultProps = {
  method: "post",
};

export default Form;
