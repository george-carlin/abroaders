import React from "react";

import FormGroup   from "../core/FormGroup";
import NumberField from "../core/NumberField";
import HelpBlock   from "../core/HelpBlock";
import InputGroup  from "../core/InputGroup";

const BusinessSpendingFormGroup = (props) =>
  <FormGroup>
    <HelpBlock>
      What is the average <b>monthly</b> spending of the business?
    </HelpBlock>

    <HelpBlock>
      Do not include business expenses that cannot be charged to a credit
      card
    </HelpBlock>

    <InputGroup addonBefore="$">
      <NumberField
        attribute={`${props.personType}_business_spending_usd`}
        defaultValue={props.defaultValue}
        min="0"
        modelName="spending_survey"
        placeholder="Estimated monthly business spending"
      />
    </InputGroup>
  </FormGroup>;

export default BusinessSpendingFormGroup;
