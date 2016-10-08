import React, { PropTypes } from "react";
import classnames from "classnames";

const Button = (_props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const props = Object.assign({}, _props);

  props.className = classnames([
    props.className,
    {
      btn: true,
      "btn-default": props.default,
      "btn-lg":      props.large,
      "btn-primary": props.primary,
      "btn-sm":      props.small,
      "btn-small":   props.small,
    },
  ]);

  return React.createElement("button", props);
};

Button.propTypes = {
  className: PropTypes.string,
  default:   PropTypes.bool,
  large:     PropTypes.bool,
  link:      PropTypes.bool,
  primary:   PropTypes.bool,
  small:     PropTypes.bool,
};

export default Button;
