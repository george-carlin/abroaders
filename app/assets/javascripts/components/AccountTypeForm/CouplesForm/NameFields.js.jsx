import React from "react";

import Alert     from "../../core/Alert";
import Button    from "../../core/Button";
import FormGroup from "../../core/FormGroup";
import TextField from "../../core/TextField";

const NameField = (_props) => {
  const props = Object.assign({}, _props);

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
          modelName="couples_account"
          placeholder="What's your partner's first name?"
          onChange={props.onChange}
          onSubmit={props.onSubmit}
          value={props.name}
        />
      </FormGroup>

      <Button
        onClick={props.onSubmit}
        primary
      >
        Sign up for couples earning
      </Button>
    </div>
  );
};

NameField.propTypes = Object.assign(
  {
    name:      React.PropTypes.string.isRequired,
    onChange:  React.PropTypes.func.isRequired,
    onSubmit:  React.PropTypes.func.isRequired,
    showError: React.PropTypes.bool,
  }
);

export default NameField;
