import React from "react";

import Alert     from "../../core/Alert";
import Button    from "../../core/Button";
import FormGroup from "../../core/FormGroup";
import TextField from "../../core/TextField";

const NameField = React.createClass({
  propTypes: {
    name:      React.PropTypes.string.isRequired,
    onChange:  React.PropTypes.func.isRequired,
    onSubmit:  React.PropTypes.func.isRequired,
    showError: React.PropTypes.bool,
  },


  onSubmitPartnerName(e) {
    e.preventDefault();
    this.props.updatePartnerName(this.state.onChangePartnerName)
  },


  render() {
    return (
      <div>
        {(() => {
          if (this.props.showError) {
            return <Alert danger >Please enter a valid name</Alert>;
          }
        })()}

        <FormGroup>
          <TextField
            attribute="partner_first_name"
            modelName="partner_account"
            placeholder="What's your partner's first name?"
            onChange={this.props.onChange}
            onSubmit={this.props.onSubmit}
            value={this.props.name}
          />
        </FormGroup>

        <Button
          onClick={this.props.onSubmit}
          primary
        >
          Sign up for couples earning
        </Button>
      </div>
    );
  },
});

module.exports = NameField;
