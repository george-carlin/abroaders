import React, { PropTypes } from "react";
import classNames from "classnames";

// a number <input> with a bootstrap form-control class and optional 'input-sm'
const NumberFieldTag = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([
    props.className,
    {
      "form-control": true,
      "input-sm":     props.small,
    },
  ]);

  return <input {...props} type="number" />;
};

NumberFieldTag.propTypes = {
  small: PropTypes.bool,
};

module.exports = NumberFieldTag;
