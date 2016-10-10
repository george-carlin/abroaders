import React      from "react";
import classnames from "classnames";

const HelpBlock = (_props) => {
  // We have to clone props because it's frozen (i.e. immutable):
  const props     = Object.assign({}, _props);
  props.className = classnames([props.className, { "help-block": true }]);
  return React.createElement("p", props);
};

export default HelpBlock;
