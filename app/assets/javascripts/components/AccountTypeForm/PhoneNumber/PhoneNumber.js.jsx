import React from "react";

import HelpBlock from "../../core/HelpBlock";
import FormGroup from "../../core/FormGroup";
import TextField from "../../core/TextField";

const PhoneNumber = React.createClass({
  propTypes: {
    modelName: React.PropTypes.string.isRequired,
  },

  render() {
    return (
      <FormGroup>
        <HelpBlock>
          Optionally, please provide a phone number we can contact you on:
        </HelpBlock>

        <TextField
          attribute="phone_number"
          modelName={this.props.modelName}
          placeholder="Phone number"
        />
      </FormGroup>
    );
  },
});

module.exports = PhoneNumber;
