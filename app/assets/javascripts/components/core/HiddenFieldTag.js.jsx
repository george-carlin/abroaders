import React, { PropTypes } from "react";

const HiddenFieldTag = (props) => {
  return <input {...props} type="hidden" />;
};

HiddenFieldTag.propTypes = {
  name:  PropTypes.string.isRequired,
  value: PropTypes.string.isRequired,
};

module.exports = HiddenFieldTag;
