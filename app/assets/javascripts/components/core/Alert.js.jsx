import React, { createElement, PropTypes } from "react";
import classnames from "classnames";


// A Bootstrap-style alert. See http://getbootstrap.com/components/#alerts
const Alert = (props) => {
  const className = classnames([
    props.className,
    {
      alert: true,
      "alert-danger"      : props.danger,
      "alert-dismissable" : props.dismissable,
      "alert-info"        : props.info,
      "alert-success"     : props.success,
      "alert-warning"     : props.warning,
    },
  ]);

  return (
    <div
      className={className}
      data-dismiss={props.dismissable ? "alert" : ""}
      role="alert"
    >
      {props.dismissable ?
        <button type="button" className="close" data-dismiss="alert">
          <span>&times;</span>
        </button> : null}
      {props.children}
    </div>
  );
};

Alert.propTypes = {
  danger:      PropTypes.bool,
  dismissable: PropTypes.bool,
  info:        PropTypes.bool,
  success:     PropTypes.bool,
  warning:     PropTypes.bool,
};

export default Alert;

