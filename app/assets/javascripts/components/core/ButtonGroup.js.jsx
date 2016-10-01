import React, { PropTypes } from "react";
const classNames = require("classnames");

const ButtonGroup = (_props) => {
  const props = Object.assign({}, _props);
  props.className = classNames([ props.className, { "btn-group": true } ]);

  return <div {...props} />;
};

ButtonGroup.propTypes = {
  className: PropTypes.string,
};

module.exports = ButtonGroup;
