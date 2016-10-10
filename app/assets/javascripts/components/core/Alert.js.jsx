import React, { PropTypes } from "react";
const classNames = require("classnames");

// A Bootstrap-style alert. See http://getbootstrap.com/components/#alerts
const Alert = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([
    props.className,
    {
      alert: true,
      "alert-danger"  : props.danger,
      "alert-info"    : props.info,
      "alert-success" : props.success,
      "alert-warning" : props.warning,
    },
  ]);

  return <div {...props} />;
};

Alert.propTypes = {
  danger:  PropTypes.bool,
  info:    PropTypes.bool,
  success: PropTypes.bool,
  warning: PropTypes.bool,
};

module.exports = Alert;
