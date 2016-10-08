import React from "react";

import HTMLInputTag from "./shared/HTMLInputTag";

// a number <input> with a bootstrap form-control class and optional 'input-sm'
const NumberFieldTag = (props) => {
  return <input {...HTMLInputTag.getProps(props)} type="number" />;
};

NumberFieldTag.propTypes = HTMLInputTag.propTypes;

export default NumberFieldTag;
