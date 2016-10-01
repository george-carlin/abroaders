const React      = require("react");
const classNames = require("classnames");

const Row = (_props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const props     = Object.assign({}, _props);
  props.className = classNames([props.className, { row: true }]);
  return <div {...props} />;
};

module.exports = Row;
