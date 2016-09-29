const React = require('react');
const _     = require("underscore");

const Row = (props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const newProps     = _.clone(props);
  newProps.className += " row";
  return <div {...newProps} />;
};

module.exports = Row;
