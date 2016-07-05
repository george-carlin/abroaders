const React = require("react");

// TODO: rename this to "TextField" and create another component called
// "TextFieldTag".  TextField inherits from TextFieldTag, and the difference is
// the same as the difference between the Rails helpers text_field and
// text_field_tag
const TextFieldTag = React.createClass({
  propTypes: {
    attribute:    React.PropTypes.string.isRequired,
    modelName:    React.PropTypes.string.isRequired,
    small:        React.PropTypes.bool,
  },

  render() {
    var name = `${this.props.modelName}[${this.props.attribute}]`;
    var id   = `${this.props.modelName}_${this.props.attribute}`;

    const props = _.clone(this.props)
    if (!props.className) props.className = "";
    const classes = props.className.split(/\s+/)

    if (!_.includes(classes, "form-control")) {
      props.className += " form-control"
    }

    if (this.props.small && !_.includes(classes, "input-sm")) {
      props.className += " input-sm"
    }

    return (
      <input
        id={id}
        className={classes}
        name={name}
        ref={this.props.refFunction}
        type="text"
        {...props}
      />
    );
  },
});

module.exports = TextFieldTag;
