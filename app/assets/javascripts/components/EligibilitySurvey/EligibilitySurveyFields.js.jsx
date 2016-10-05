import React from "react";
import { map } from "underscore";

const Button = require("../core/Button");
const Radio  = require("../core/Radio");

const values = ["both", "owner", "companion", "neither"];

const EligibilitySurveyFields = ({account}) => {
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

    return map(values, (value, i) => {
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
  }

  return (
    <div>
      <Radio
        attribute={attribute}
        defaultChecked
        labelText="Yes - I am eligible"
        modelName={modelName}
        value="true"
      />

      <Radio
        attribute={attribute}
        labelText="No - I am not eligible"
        modelName={modelName}
        value="false"
      />
    </div>
  );
};

module.exports = EligibilitySurveyFields;
