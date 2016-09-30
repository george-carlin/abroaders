const React = require("react");

const FormGroup   = require("../core/FormGroup");
const InputGroup  = require("../core/InputGroup");
const NumberField = require("../core/NumberField");

const HelpText = require("./MonthlySpendingHelpText");

const MonthlySpendingFormGroup = ({modelName}) => {
  return (
    <FormGroup>
      <InputGroup addonBefore="$" >
        <NumberField
          attribute="monthly_spending_usd"
          min="0"
          modelName={modelName}
          placeholder="Estimated monthly spending"
        />
      </InputGroup>
    </FormGroup>
  );
};

MonthlySpendingFormGroup.propTypes = {
  modelName: React.PropTypes.string.isRequired,
};

module.exports = MonthlySpendingFormGroup;
