import React, { PropTypes } from "react";

import FormGroup   from "../core/FormGroup";
import HelpBlock   from "../core/HelpBlock";
import NumberField from "../core/NumberField";

const CreditScoreFormGroup = (props) =>
  <FormGroup className={props.className}>
    <h3>
      What is {props.useName ? <b>{props.firstName}'s</b> : " your "} credit score?
    </h3>

    <HelpBlock>
      A credit score should be a number between 350 and 850
    </HelpBlock>

    <NumberField
      attribute={`${props.personType}_credit_score`}
      defaultValue={props.defaultValue}
      max="850"
      min="350"
      modelName="spending_survey"
    />
  </FormGroup>;

CreditScoreFormGroup.propTypes = {
  className:  PropTypes.string,
  firstName:  PropTypes.string.isRequired,
  personType: PropTypes.oneOf(["owner", "companion"]).isRequired,
  useName:    PropTypes.bool,
};

export default CreditScoreFormGroup;
