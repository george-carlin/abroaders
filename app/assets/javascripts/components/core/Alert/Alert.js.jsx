const React = require("react");

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

    if (!props.className) props.className = "";

    const classes = props.className.split(/\s+/)
    if (!_.includes(classes, "alert")) props.className += " alert";

    if (props.danger && !_.includes(classes, " alert-danger")) {
      props.className += " alert-danger";
    }

    if (props.info && !_.includes(classes, " alert-info")) {
      props.className += " alert-info";
    }

    if (props.warning && !_.includes(classes, " alert-warning")) {
      props.className += " alert-warning";
    }

    if (props.success && !_.includes(classes, " alert-success")) {
      props.className += " alert-success";
    }

    return (
      <div {...props}>
        {this.props.children}
      </div>
    );
  },
});

module.exports = Alert;
