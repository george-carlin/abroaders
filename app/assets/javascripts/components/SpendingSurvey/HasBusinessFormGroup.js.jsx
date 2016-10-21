import React, { PropTypes } from "react";

import HelpBlock from "../core/HelpBlock";
import Radio     from "../core/Radio";

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
        {props.useName ? <b>{props.firstName}</b> : "you"}
        &nbsp;have a business?
      </h3>

      <HelpBlock>
        Small business cards offer excellent opportunities to earn rewards
        points. If you own a business or work as a freelancer, we’ll help you
        turn your business spending into valuable rewards too.
      </HelpBlock>

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
