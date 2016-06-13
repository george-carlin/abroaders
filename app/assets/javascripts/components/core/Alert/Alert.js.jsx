const React      = require("react");
const _          = require("underscore");
const classNames = require("classnames");

const Alert = React.createClass({
  propTypes: {
    danger:  React.PropTypes.bool,
    info:    React.PropTypes.bool,
    success: React.PropTypes.bool,
    warning: React.PropTypes.bool,
  },

  render() {
    // We have to clone props because it's frozen (i.e. immutable):
    const props   = _.clone(this.props);

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

    return (
      <div {...props}>
        {this.props.children}
      </div>
    );
  },
});

module.exports = Alert;
