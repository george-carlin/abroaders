import React, { PropTypes } from "react";

import Button from "../../core/Button";
import FAIcon from "../../core/FAIcon";
import Form   from "../../core/Form";

import HiddenField from "../../core/HiddenField";

const MonthlySpending = require("../MonthlySpending");
const PhoneNumber     = require("../PhoneNumber");

const Eligibility     = require("./Eligibility");
const NameFields      = require("./NameFields");

const CouplesForm = React.createClass({
  propTypes: {
    ownerName: PropTypes.string.isRequired,
    path:      PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      companionName: "",
      showError:     false,
    };
  },


  onChangeEligibility(e) {
    this.setState({eligibility: e.target.value});
  },


  onChangeCompanionName(e) {
    this.setState({ companionName: e.target.value });
  },


  onSubmit(e) {
    if (this.state.companionName.length) {
      this.setState({ showError: false});
    } else {
      e.preventDefault();
      this.setState({ showError: true });
    }
  },


  render() {
    const modelName = "couples_account";

    return (
      <Form
        action={this.props.path}
        className="CouplesForm account_type_select well col-xs-12 col-md-4"
        method="post"
        onSubmit={this.onSubmit}
      >
        <h2>
          <FAIcon user />
          <FAIcon user />
          &nbsp;
          Couples Earning
        </h2>

        {(() => {
          if (this.state.nameSubmitted) {
            return (
              <div className="account_type_form_step_1">
                <HiddenField
                  attribute="companion_first_name"
                  modelName={modelName}
                  type="hidden"
                  value={this.state.companionName}
                />

                <hr />

                <Button primary >
                  Submit
                </Button>
              </div>
            );
          } else {
            return (
              <div>
                <p>
                  This option is ideal if you share monthly spending with a
                  spouse or partner. Abroaders will help you maximize your
                  points as a team.
                </p>

                <p>
                  Couples earning only works if you pay your bills together. If
                  you would prefer to keep your expenses separate and pay
                  separately for your own monthly purchases, you should each
                  create your own Abroaders account and choose "Solo Earning"
                </p>

                <NameFields
                  name={this.state.companionName}
                  onChange={this.onChangeCompanionName}
                  onSubmit={this.onSubmitCompanionName}
                  showError={this.state.showError}
                />
              </div>
            );
          }
        })()}

      </Form>
    );
  },
});

module.exports = CouplesForm;
