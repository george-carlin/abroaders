import React, { PropTypes } from "react";

import Radio from "../core/Radio";

const radios = [
  {
    label: "Yes, with an EIN (Employer ID Number)",
    value: "with_ein",
  }, {
    label: "Yes, without an EIN (Employer ID Number)",
    value: "without_ein",
  }, {
    label: "No, I don't own a business",
    value: "no_business",
  },
];

const HasBusinessFormGroup = (props) => {
  return (
    <div>
      <h3>
        {props.useName ? "Does " : "Do "}
        {props.useName ? <b>{props.firstName}</b> : " you "}
        have a business?
      </h3>

      {radios.map((radio) =>
        <Radio
          attribute={`${props.personType}_has_business`}
          defaultChecked={props.defaultValue === radio.value}
          key={radio.value}
          labelText={radio.label}
          modelName="spending_survey"
          onChange={props.onChange}
          value={radio.value}
        />)
      }
    </div>
  );
};

HasBusinessFormGroup.propTypes = {
  defaultValue: PropTypes.string.isRequired,
  firstName:    PropTypes.string.isRequired,
  onChange:     PropTypes.func.isRequired,
  personType:   PropTypes.string.isRequired,
  useName:      PropTypes.bool,
};

export default HasBusinessFormGroup;
