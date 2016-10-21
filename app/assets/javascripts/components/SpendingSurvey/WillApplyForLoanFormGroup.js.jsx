import React, { PropTypes } from "react";
import { map } from "underscore";

import SpanWithTooltip from "../SpanWithTooltip";

import FormGroup from "../core/FormGroup";
import Radio     from "../core/Radio";

const tooltipText = `Your credit score is especially important right before ` +
  `you apply for a loan or mortgage. Although the strategies we recommend ` +
  `should have a positive effect on your credit over time, it is common to ` +
  `see a small drop in your credit score immediately after you apply for ` +
  `a new card. If you answer yes to this question, we may recommend ` +
  `you wait until after you’ve applied for the loan before opening new cards.`;

const WillApplyForLoanFormGroup = (props) => {
  const attribute = `${props.personType}_will_apply_for_loan`;

  return (
    <FormGroup className={props.className}>
      <h3>
        {props.useName ? "Does " : "Do "}
        {props.useName ? <b>{props.firstName}</b> : "you"}&nbsp;
        plan to apply for a loan of over $5,000 in the next 12 months?
        &nbsp;
        <small>
          <SpanWithTooltip title={tooltipText}>
            More info
          </SpanWithTooltip>
        </small>
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
