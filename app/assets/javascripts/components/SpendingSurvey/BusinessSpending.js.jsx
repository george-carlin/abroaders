const React = require("react");

const FormGroup  = require("../core/FormGroup");
const HelpBlock  = require("../core/HelpBlock");
const InputGroup = require("../core/InputGroup");

const BusinessSpending = (props) => {
  return (
    <FormGroup>
      <HelpBlock>
        What is the average <b>monthly</b> spending of the business?
      </HelpBlock>

      <HelpBlock>
        Do not include business expenses that cannot be charged to a credit
        card
      </HelpBlock>

      <InputGroup addonBefore="$">
        <input className="form-control" type="number" />
      </InputGroup>
    </FormGroup>
  );
};

module.exports = BusinessSpending;
