const React      = require("react");
const classNames = require("classnames");
const _          = require("underscore");

const FormGroup = (_props) => {
  const props = _.clone(_props);

  props.className = classNames([props.className, { "form-group": true }]);

  return <div {...props} />;
};

module.exports = FormGroup;
