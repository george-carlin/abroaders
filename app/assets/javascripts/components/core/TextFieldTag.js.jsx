import React, { PropTypes } from "react";
import classNames from "classnames";

// a text <input> with a bootstrap form-control class and optional 'input-sm'
const TextFieldTag = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([
    props.className,
    {
      "form-control": true,
      "input-sm":     props.small,
    },
  ]);

  return <input {...props} type="text" />;
};

TextFieldTag.propTypes = {
  small: PropTypes.bool,
};

module.exports = TextFieldTag;
