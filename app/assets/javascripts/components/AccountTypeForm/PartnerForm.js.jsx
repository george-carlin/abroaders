import React, { PropTypes } from "react";

import Alert     from "../core/Alert";
import Button    from "../core/Button";
import FAIcon    from "../core/FAIcon";
import Form      from "../core/Form";
import FormGroup from "../core/FormGroup";
import TextField from "../core/TextField";

const PartnerForm = React.createClass({
  propTypes: {
    ownerName: PropTypes.string.isRequired,
    path:      PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      partnerName: "",
      showError:   false,
    };
  },


  onSubmit(e) {
    if (this.state.partnerName.trim().length) {
      this.setState({showError: false});
      // Let the form submit in the regular HTML way
    } else {
      this.setState({showError: true});
      // Prevent the form from submitting:
      e.preventDefault();
    }
  },


  onChangePartnerName(e) {
    this.setState({ partnerName: e.target.value });
  },


  render() {
    return (
      <Form
        action={this.props.path}
        className="PartnerForm account_type_select well col-xs-12 col-md-4"
        method="post"
      >
        <h2>
          <FAIcon user />
          <FAIcon user />
          &nbsp;
          Couples Earning
        </h2>

        <p>
          This option is ideal if you share monthly spending with a spouse or
          partner. Abroaders will help you maximize your points as a team.
        </p>

        <p>
          Couples earning only works if you pay your bills together. If you
          would prefer to keep your expenses separate and pay separately for
          your own monthly purchases, you should each create your own Abroaders
          account and choose "Solo Earning"
        </p>

        {(() => {
          if (this.state.showError) {
            return <Alert danger >Please enter a valid name</Alert>;
          }
        })()}

        <FormGroup>
          <TextField
            attribute="partner_first_name"
            modelName="partner_account"
            placeholder="What's your partner's first name?"
            onChange={this.onChangePartnerName}
            onSubmit={this.onSubmit}
          />
        </FormGroup>

        <Button
          onClick={this.onSubmit}
          primary
        >
          Sign up for couples earning
        </Button>
      </Form>
    );
  },
});

module.exports = PartnerForm;
