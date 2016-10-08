import React, { PropTypes } from "react";

import RadioButton from "./RadioButton";

// A RadioButton tag wrapped in a bootstrap-style <div class="radio">
// and given a label. Specify the label text with the 'labelText' prop;
// all other props are passed down to RadioButton.
const Radio = (_props) => {
  const props     = Object.assign({}, _props);
  const labelText = props.labelText;
  delete props.labelText;

  return (
    <div className="radio">
      <label>
        <RadioButton {...props} />
        {labelText}
      </label>
    </div>
  );
};

Radio.propTypes = Object.assign(
  {},
  RadioButton.propTypes,
  {
    labelText: PropTypes.string,
  }
);

export default Radio;
