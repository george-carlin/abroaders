import React      from "react";
import classnames from "classnames";

import columnClassnames from "./shared/columnClassnames";

// Outputs Bootstrap-style 'col-xs-12', 'col-md-5', 'col-lg-offset-3' divs:
//
// <Cols xs="12" md="6" mdOffset="3" /> // =>
// <div class="col-xs-12 col-md-6 col-md-offset-3" />
//
const Cols = (_props) => {
  const props = Object.assign({}, _props);

  props.className = classnames([
    props.className,
    columnClassnames(props),
  ]);
  return React.createElement("div", props);
};

export default Cols;
