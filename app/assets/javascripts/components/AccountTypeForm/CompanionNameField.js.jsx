import React, { PropTypes } from "react";

import Alert     from "../core/Alert";
import Button    from "../core/Button";
import FormGroup from "../core/FormGroup";
import TextField from "../core/TextField";

const CompanionNameField = (props) => {
  return (
    <div>
      {(() => {
        if (props.showError) {
          return <Alert danger >Please enter a valid name</Alert>;
        }
      })()}

      <FormGroup>
        <TextField
          attribute="companion_first_name"
          modelName={props.modelName}
          placeholder="What's your partner's first name?"
          onChange={props.onChange}
          value={props.name}
        />
      </FormGroup>
    </div>
  );
};

CompanionNameField.propTypes = {
  modelName: PropTypes.string.isRequired,
  name:      PropTypes.string.isRequired,
  onChange:  PropTypes.func.isRequired,
  showError: PropTypes.bool,
};

export default CompanionNameField;
