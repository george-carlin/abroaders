const React = require("react");

// TODO: rename this to "TextField" and create another component called
// "TextFieldTag".  TextField inherits from TextFieldTag, and the difference is
// the same as the difference between the Rails helpers text_field and
// text_field_tag
const TextFieldTag = React.createClass({
  propTypes: {
    attribute:    React.PropTypes.string.isRequired,
    modelName:    React.PropTypes.string.isRequired,
  },

  render() {
    var name = `${this.props.modelName}[${this.props.attribute}]`;
    var id   = `${this.props.modelName}_${this.props.attribute}`;

    var props = _.clone(this.props)
    var classes = `form-control ${props.className}`
    delete props.className;

    return (
      <input
        id={id}
        className={classes}
        name={name}
        type="text"
        {...props}
      />
    );
  },
});

module.exports = TextFieldTag;
