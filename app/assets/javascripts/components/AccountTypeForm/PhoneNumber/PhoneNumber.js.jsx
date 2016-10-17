import React from "react";

import HelpBlock from "../../core/HelpBlock";
import FormGroup from "../../core/FormGroup";
import TextField from "../../core/TextField";

const PhoneNumber = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <FormGroup>
      <HelpBlock>
        Optionally, please provide a phone number we can contact you on:
      </HelpBlock>

      <TextField
        attribute="phone_number"
        modelName={props.modelName}
        placeholder="Phone number"
      />
    </FormGroup>
  );
};

PhoneNumber.propTypes = Object.assign(
  {
    modelName: React.PropTypes.string.isRequired,
  }
);

export default PhoneNumber;
