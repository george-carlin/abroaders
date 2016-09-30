import React, { PropTypes } from "react";

import FormGroup   from "../core/FormGroup";
import HelpBlock   from "../core/HelpBlock";
import InputGroup  from "../core/InputGroup";
import NumberField from "../core/NumberField";


// // TODO wording based on who is eligible or just if they're there?
// const names = [account.owner.firstName];
// if (account.companion) {
//   names.push(account.companion.firstName);
// }
//
//
//   <HelpBlock>
//     Please estimate the <b>combined</b> monthly spending
//     for {firstNames.join(" and ")} that could be charged to a credit card
//     account.
//   </HelpBlock>

const MonthlySpendingFormGroup = ({className, defaultValue}) =>
  <FormGroup className={className}>
    <h3>How much do you spend per month?</h3>

    <HelpBlock>
      What is your average monthly personal spending that could be charged
      to a credit card account?
    </HelpBlock>

    <HelpBlock>
      You should exclude rent, mortage, and car payments unless you are
      certain you can use a credit card as the payment method.
    </HelpBlock>

    <InputGroup addonBefore="$" >
      <NumberField
        attribute="monthly_spending"
        defaultValue={defaultValue}
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
