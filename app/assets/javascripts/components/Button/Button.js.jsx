"use strict";

const React = require("react");
const _     = require("underscore");

const Button = React.createClass({
  render() {
    // We have to clone props because it's frozen (i.e. immutable):
    const props   = _.clone(this.props);

    if (!props.className) props.className = "";

    const classes = props.className.split(/\s+/)

    if (!_.includes(classes, "btn")) props.className += " btn";

    if (props.small && !_.includes(classes, "btn-sm")) {
      props.className += " btn-sm";
    }

    if (props.default && !_.includes(classes, "btn-default")) {
      props.className += " btn-default";
    }

    if (props.primary && !_.includes(classes, "btn-primary")) {
      props.className += " btn-primary";
    }

    return (
      <button {...props} />
    );
  },
});

module.exports = Button;
