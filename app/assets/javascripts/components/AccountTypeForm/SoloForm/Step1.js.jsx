import React from "react";

import Button    from "../../core/Button";
import HelpBlock from "../../core/HelpBlock";

import MonthlySpending from "../MonthlySpending";
import PhoneNumber     from "../PhoneNumber";

import Eligibility from "./Eligibility";

const Step1 = React.createClass({
  propTypes: {
    isEligibleToApply:        React.PropTypes.bool.isRequired,
    monthlySpending:          React.PropTypes.number,
    ownerName:                React.PropTypes.string.isRequired,
    onChangeEligibility:      React.PropTypes.func.isRequired,
    onChangeMonthlySpending:  React.PropTypes.func.isRequired,
    showMonthlySpendingError: React.PropTypes.bool,
  },

  getNamesOfEligiblePeople() {
    let result;
    if (this.props.isEligibleToApply) {
      result = [this.props.ownerName];
    } else {
      result = [];
    }
    return result;
  },

  render() {
    const modelName = "solo_account";

    return (
      <div className="account_type_form_step_1">

        <Eligibility
          isEligibleToApply={this.props.isEligibleToApply}
          onChange={this.props.onChangeEligibility}
        />

        <hr />

        <MonthlySpending
          isSoloPlan
          modelName={modelName}
          monthlySpending={this.props.monthlySpending}
          namesOfEligiblePeople={this.getNamesOfEligiblePeople()}
          onChange={this.props.onChangeMonthlySpending}
          showError={this.props.showMonthlySpendingError}
        />

        <PhoneNumber
          modelName={modelName}
        />

        <Button primary >
          Submit
        </Button>
      </div>
    );
  },
});

export default Step1;
