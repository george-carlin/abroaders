import React, { PropTypes } from "react";
import classnames from "classnames";

const ButtonGroup = (_props) => {
  const props = Object.assign({}, _props);
  props.className = classnames([ props.className, { "btn-group": true } ]);

  return React.createElement("div", props);
};

ButtonGroup.propTypes = {
  className: PropTypes.string,
};

export default ButtonGroup;
