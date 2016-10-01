const React      = require("react");
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
  danger:  React.PropTypes.bool,
  info:    React.PropTypes.bool,
  success: React.PropTypes.bool,
  warning: React.PropTypes.bool,
};

module.exports = Alert;
