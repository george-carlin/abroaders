import React      from "react";
import classnames from "classnames";

const FormGroup = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classnames([props.className, { "form-group": true }]);

  return React.createElement("div", props);
};

export default FormGroup;
