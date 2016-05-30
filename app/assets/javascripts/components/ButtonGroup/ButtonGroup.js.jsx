const React = require("react");
const _     = require("underscore");

const ButtonGroup = React.createClass({
  propTypes: {
    className: React.PropTypes.string,
  },

  render() {
    const className = this.props.className || "";
    const classes   = className.split(/\s+/);

    if (!_.includes(classes, "btn-group")) {
      classes.push("btn-group");
    }

    return (
      <div className={classes.join(" ")}>
        {this.props.children}
      </div>
    );
  },
});

module.exports = ButtonGroup;
