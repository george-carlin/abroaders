import React, { PropTypes } from "react";
import { map } from "underscore";

import FormGroup from "../core/FormGroup";
import Radio     from "../core/Radio";

const WillApplyForLoanFormGroup = (props) => {
  const attribute = `${props.personType}_will_apply_for_loan`;

  return (
    <FormGroup className={props.className}>
      <h3>
        {props.useName ? "Does " : "Do "}
        {props.useName ? <b>{props.firstName}</b> : " you "}
        plan to apply for a loan of over $5,000 in the next 12 months?
      </h3>

      {map({ Yes: "true", No: "false"}, (value, label) =>
        <Radio
          attribute={attribute}
          defaultChecked={props.defaultValue === value}
          key={label}
          modelName="spending_survey"
          labelText={label}
          value={value}
        />
      )}
    </FormGroup>
  );
};

WillApplyForLoanFormGroup.propTypes = {
  className:  PropTypes.string.isRequired,
  firstName:  PropTypes.string.isRequired,
  personType: PropTypes.string.isRequired,
  useName:    PropTypes.bool,
};

export default WillApplyForLoanFormGroup;
