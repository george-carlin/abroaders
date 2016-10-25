import React, { PropTypes } from "react";

import FormGroup   from "../core/FormGroup";
import HelpBlock   from "../core/HelpBlock";
import InputGroup  from "../core/InputGroup";
import NumberField from "../core/NumberField";

const MonthlySpendingFormGroup = (props) =>
  <FormGroup className={props.className}>
    <h3>How much do you spend per month?</h3>

    {
      props.isCouplesAccount ?
       <HelpBlock>
         Please estimate the <b>combined</b> monthly spending
         for {props.ownerFirstName} and {props.companionFirstName} that could
         be charged to a credit card account.
       </HelpBlock>
       :
       <HelpBlock>
         What is your average monthly personal spending that could be charged
         to a credit card account?
       </HelpBlock>
    }

    <HelpBlock>
      You should exclude rent, mortage, and car payments unless you are
      certain you can use a credit card as the payment method.
    </HelpBlock>

    <InputGroup addonBefore="$" >
      <NumberField
        attribute="monthly_spending"
        defaultValue={props.defaultValue}
        min="0"
        modelName="spending_survey"
        placeholder="Estimated monthly spending"
      />
    </InputGroup>
  </FormGroup>;

MonthlySpendingFormGroup.propTypes = {
  className: PropTypes.string,
};

export default MonthlySpendingFormGroup;
