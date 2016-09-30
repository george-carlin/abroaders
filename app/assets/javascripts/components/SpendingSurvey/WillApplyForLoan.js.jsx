const React = require("react");

const FormGroup = require("../core/FormGroup");
const Radio     = require("../core/Radio");

const WillApplyForLoan = ({className, modelName, person, useName}) => {
  let title;
  const suffix = "plan to apply for a loan of over $5,000 in the next 12 months?";
  if (useName) {
    title = <h3>Does <b>{person.firstName}</b> {suffix}</h3>;
  } else {
    title = <h3>Do you {suffix}</h3>;
  }

  const attribute = `${person.type}_will_apply_for_loan`;

  return (
    <div className={className}>
      <FormGroup>
        {title}

        <Radio
          attribute={attribute}
          modelName={modelName}
          labelText="Yes"
          value="true"
        />
        <Radio
          attribute={attribute}
          modelName={modelName}
          labelText="No"
          value="false"
        />
      </FormGroup>
    </div>
  );
};

module.exports = WillApplyForLoan;
