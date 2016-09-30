const React = require("react");

// modelName: "person", attribute: "ready", value="true" will create a radio
// button with name="person[ready]" and value="true". This keeps things in line
// with the attribute names in a normal Rails form
const RadioButton = React.createClass({
  propTypes: {
    attribute: React.PropTypes.string.isRequired,
    modelName: React.PropTypes.string.isRequired,
    value:     React.PropTypes.string.isRequired,
    checked:   React.PropTypes.bool,
  },

  render() {
    const id   = `${this.props.modelName}_${this.props.attribute}_${this.props.value}`,
          name = `${this.props.modelName}[${this.props.attribute}]`;

    const props = _.clone(this.props);

    delete props.modelName;
    delete props.attribute;

    return (
      <input
        type="radio"
        name={name}
        id={id}
        checked={this.props.checked}
        {...props}
      />
    );
  },
});

module.exports = RadioButton;
