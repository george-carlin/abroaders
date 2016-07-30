const React = require("react");

const NumberField = React.createClass({
  propTypes: {
    attribute: React.PropTypes.string.isRequired,
    modelName: React.PropTypes.string.isRequired,
    small:     React.PropTypes.bool,
  },

  render() {
    const id   = `${this.props.modelName}_${this.props.attribute}`,
          name = `${this.props.modelName}[${this.props.attribute}]`;

    const props = _.clone(this.props);
    if (!props.className) props.className = "";
    const classes = props.className.split(/\s+/);

    if (!_.includes(classes, "form-control")) {
      props.className += " form-control";
    }

    if (this.props.small && !_.includes(classes, "input-sm")) {
      props.className += " input-sm";
    }

    return (
      <input
        id={id}
        className={classes}
        name={name}
        type="number"
        {...props}
      />
    );
  },
});

module.exports = NumberField;
