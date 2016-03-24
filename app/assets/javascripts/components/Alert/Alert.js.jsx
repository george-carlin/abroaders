const React = require("React");

const Alert = React.createClass({

  propTypes: {
    danger:  React.PropTypes.bool,
    info:    React.PropTypes.bool,
    success: React.PropTypes.bool,
    warning: React.PropTypes.bool,
  },

  render() {
    var classes = ["alert"]

    if (this.props.danger)  { classes.push("alert-danger"); }
    if (this.props.info)    { classes.push("alert-info"); }
    if (this.props.success) { classes.push("alert-success"); }
    if (this.props.warning) { classes.push("alert-warning"); }

    return (
      <div
        className={classes.join(" ")}
        {...this.props}
      >
        {this.props.children}
      </div>
    );
  },

});

module.exports = Alert;
