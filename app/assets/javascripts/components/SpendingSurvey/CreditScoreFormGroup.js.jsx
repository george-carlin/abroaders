import React, { PropTypes } from "react";

import SpanWithTooltip from "../SpanWithTooltip";

import FormGroup   from "../core/FormGroup";
import HelpBlock   from "../core/HelpBlock";
import NumberField from "../core/NumberField";

// TODO isn't there an ES6 thing that lets me comfortably span strings over
// multiple lines?
const tooltipText = `We ask for your credit score to make sure we only ` +
                    `recommend cards for which you’re likely to be approved. ` +
                    `The strategies we recommend to maximize rewards should ` +
                    `improve your credit over time. If you're not sure what ` +
                    `your credit score is, please give us your best guess.`;

const CreditScoreFormGroup = (props) =>
  <FormGroup className={props.className}>
    <h3>
      What is&nbsp;{props.useName ? <b>{props.firstName}'s</b> : "your"}&nbsp;credit score?
      &nbsp;
      <small>
        <SpanWithTooltip title={tooltipText} >
          More info
        </SpanWithTooltip>
      </small>
    </h3>

    <HelpBlock>
      A credit score should be a number between 350 and 850.&nbsp;
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
