const React      = require("react");
const classNames = require("classnames");

const FormGroup = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classNames([props.className, { "form-group": true }]);

  return <div {...props} />;
};

module.exports = FormGroup;
