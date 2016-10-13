import React from "react";

import Radio     from "../../core/Radio";
import HelpBlock from "../../core/HelpBlock";

const Eligibility = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <div className="Eligibility">
      <HelpBlock>
        Are you eligible to apply for credit cards issued by banks in the
        United States?
      </HelpBlock>

      <HelpBlock>
        You generally need to be either a U.S. citizen or a permanent
        resident to be approved for cards issued by U.S. Banks.
      </HelpBlock>

      <Radio
        attribute="eligible"
        checked={props.isEligibleToApply}
        className="solo_account_eligible"
        labelText="Yes - I am eligible"
        modelName="solo_account"
        onChange={() => props.onChange(true) }
        value="true"
      />

      <Radio
        attribute="eligible"
        checked={!props.isEligibleToApply}
        className="solo_account_eligible"
        labelText="No - I am not eligible"
        modelName="solo_account"
        onChange={() => props.onChange(false) }
        value="false"
      />
    </div>
  );
};

Eligibility.propTypes = Object.assign(
  {
    isEligibleToApply: React.PropTypes.bool.isRequired,
    onChange:          React.PropTypes.func.isRequired,
  }
);

export default Eligibility;
