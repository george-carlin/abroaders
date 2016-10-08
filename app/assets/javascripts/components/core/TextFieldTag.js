import React from "react";

import HTMLInputTag from "./shared/HTMLInputTag";

// a text <input> with a bootstrap form-control class and optional 'input-sm'
const TextFieldTag = (props) => {
  return React.createElement(
    "input",
    HTMLInputTag.getProps(props, { type: "text" })
  );
};

TextFieldTag.propTypes = HTMLInputTag.propTypes;

export default TextFieldTag;
