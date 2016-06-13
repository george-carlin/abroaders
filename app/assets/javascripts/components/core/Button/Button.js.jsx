const React      = require("react");
const classNames = require("classnames");
const _          = require("underscore");

const Button = React.createClass({
  propTypes: {
    className: React.PropTypes.string,
    default:   React.PropTypes.bool,
    large:     React.PropTypes.bool,
    link:      React.PropTypes.bool,
    primary:   React.PropTypes.bool,
    small:     React.PropTypes.bool,
  },

  render() {
    // We have to clone props because it's frozen (i.e. immutable):
    const props = _.clone(this.props);

    props.className = classNames([
      props.className,
      {
        btn: true,
        "btn-default": props.default,
        "btn-lg":      props.large,
        "btn-primary": props.primary,
        "btn-sm":      props.small,
        "btn-small":   props.small,
      },
    ]);

    return (
      <button {...props} />
    );
  },
});

module.exports = Button;
