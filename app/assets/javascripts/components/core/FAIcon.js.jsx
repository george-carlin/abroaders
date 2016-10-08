import React from "react";

// Example usage:
//
// <FAIcon plus /> will output:
//
// <i class="fa fa-plus"> </i>
//
// Only pass ONE prop to the component, or it won't work.
const FAIcon = (props) => {
  return <i className={`fa fa-${Object.keys(props)[0]}`} > </i>;
};

export default FAIcon;
