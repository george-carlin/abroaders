const React      = require("react");
const classNames = require("classnames");
const _          = require("underscore");

const HelpBlock = (_props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const props     = Object.assign({}, _props);
  props.className = classNames([props.className, { "help-block": true }]);
  return <p {...props} />;
};

module.exports = HelpBlock;
