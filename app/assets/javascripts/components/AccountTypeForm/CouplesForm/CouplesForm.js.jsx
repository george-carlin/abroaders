import React from "react";

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
    active:    React.PropTypes.bool,
    ownerName: React.PropTypes.string.isRequired,
    onChoose:  React.PropTypes.func.isRequired,
    path:      React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      monthlySpending:          null,
      nameSubmitted:            false,
      companionName:            "",
      showMonthlySpendingError: false,
      showCompanionNameError:   false,
      eligibility:              "both",
    };
  },


  onChangeEligibility(e) {
    this.setState({eligibility: e.target.value});
  },


  onChangeMonthlySpending(e) {
    this.setState({monthlySpending: parseInt(e.target.value, 10)});
  },


  onChangeCompanionName(e) {
    this.setState({ companionName: e.target.value });
  },


  onSubmit(e) {
    if (this.state.nameSubmitted) {
      if (this.state.eligibility !== "neither" && !this.isMonthlySpendingPresentAndValid()) {
        e.preventDefault();
        this.setState({showMonthlySpendingError: true });
      } else {
        this.setState({showMonthlySpendingError: false });
      }
    } else {
      this.onSubmitCompanionName(e);
    }
  },


  onSubmitCompanionName(e, name) {
    e.preventDefault();

    if (this.state.companionName.length) {
      this.setState({ showCompanionNameError: false, nameSubmitted: true });
      this.props.onChoose();
    } else {
      this.setState({ showCompanionNameError: true });
    }
  },

  isMonthlySpendingPresentAndValid() {
    return this.state.monthlySpending && this.state.monthlySpending > 0;
  },


  render() {
    let classes = "CouplesForm account_type_select well col-xs-12 col-md-4";
    if (this.props.active) classes += " col-md-offset-4";

    const modelName = "couples_account";

    let namesOfEligiblePeople;
    switch (this.state.eligibility) {
      case "both":
        namesOfEligiblePeople = [this.props.ownerName, this.state.companionName];
        break;
      case "person_0":
        namesOfEligiblePeople = [this.props.ownerName];
        break;
      case "person_1":
        namesOfEligiblePeople = [this.state.companionName];
        break;
      case "neither":
        namesOfEligiblePeople = [];
        break;
    }

    return (
      <Form
        action={this.props.path}
        className={classes}
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

                <Eligibility
                  eligibility={this.state.eligibility}
                  onChange={this.onChangeEligibility}
                  person1FirstName={this.props.ownerName}
                  person2FirstName={this.state.companionName}
                />

                <hr />

                <MonthlySpending
                  eligibility={this.state.eligibility}
                  modelName={modelName}
                  namesOfEligiblePeople={namesOfEligiblePeople}
                  onChange={this.onChangeMonthlySpending}
                  person0FirstName={this.props.ownerName}
                  person1FirstName={this.state.companionName}
                  showError={this.state.showMonthlySpendingError}
                  value={this.state.monthlySpending}
                />

                <PhoneNumber
                  modelName={modelName}
                />

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
                  showError={this.state.showCompanionNameError}
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
