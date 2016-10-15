import React, { PropTypes } from "react";

import Radio from "../core/Radio";

const values = ["both", "owner", "companion", "neither"];

const Fields = ({account}) => {
  const modelName = "eligibility_survey";
  const attribute = "eligible";

  if (account.companion) {
    const ownerName = account.owner.firstName;
    const compName  = account.companion.firstName;
    const labels = {
      both: `Both ${ownerName} and ${compName} are eligible.`,
      owner: `Only ${ownerName} is eligible.`,
      companion: `Only ${compName} is eligible.`,
      neither:  "Neither of us is eligible.",
    };

    const radios = values.map((value, i) => {
      return (
        <Radio
          attribute={attribute}
          defaultChecked={value === "both"}
          key={i}
          labelText={labels[value]}
          modelName={modelName}
          value={value}
        />
      );
    });
    // (Stateless React components can't return arrays)
    return <div>{radios}</div>;
  }

  return (
    <div>
      <Radio
        attribute={attribute}
        defaultChecked
        labelText="Yes - I am eligible"
        modelName={modelName}
        value="owner"
      />

      <Radio
        attribute={attribute}
        labelText="No - I am not eligible"
        modelName={modelName}
        value="neither"
      />
    </div>
  );
};

Fields.propTypes = {
  account: PropTypes.object.isRequired,
};

export default Fields;
