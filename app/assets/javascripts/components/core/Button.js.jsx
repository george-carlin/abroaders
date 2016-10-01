const React      = require("react");
const classNames = require("classnames");

const Button = (_props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const props = Object.assign({}, _props);

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

  return <button {...props} />;
};

Button.propTypes = {
  className: React.PropTypes.string,
  default:   React.PropTypes.bool,
  large:     React.PropTypes.bool,
  link:      React.PropTypes.bool,
  primary:   React.PropTypes.bool,
  small:     React.PropTypes.bool,
};

module.exports = Button;
