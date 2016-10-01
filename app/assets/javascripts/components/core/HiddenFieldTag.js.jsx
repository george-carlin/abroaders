const React = require("react");

const HiddenFieldTag = (props) => {
  return <input {...props} type="hidden" />;
};

HiddenFieldTag.propTypes = {
  name:  React.PropTypes.string.isRequired,
  value: React.PropTypes.string.isRequired,
};

module.exports = HiddenFieldTag;
