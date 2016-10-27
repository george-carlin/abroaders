import React from "react";

import numbro from "numbro";

const SpendingInfo = React.createClass({
  propTypes: {
    account: React.PropTypes.object.isRequired,
    person: React.PropTypes.object.isRequired,
    spendingInfo: React.PropTypes.object.isRequired,
  },

  numberToCurrency(number) {
    return numbro(number).format("$0,0.00");
  },

  monthlySpendingLabel() {
    return (this.hasCompanion() ? "Shared" : "Personal") + " spending";
  },

  willApplyForLoanLabel() {
    return this.props.spendingInfo.willApplyForLoan ? "Yes" : "No";
  },

  hasCompanion() {
    return !!this.props.account.companion;
  },

  hasBusiness() {
    return (this.props.spendingInfo.hasBusiness !== "no_business");
  },

  businessEinLabel() {
    if (this.hasBusiness()) {
      if (this.props.spendingInfo.hasBusiness === "with_ein") {
        return "(Has EIN)";
      } else {
        return "(Does not have EIN)";
      }
    }
  },

  businessSpending() {
    if (this.hasBusiness()) {
      return this.numberToCurrency(this.props.spendingInfo.businessSpendingUsd);
    } else {
      return "No business";
    }
  },

  render() {
    const person = this.props.person;

    return (
      <table className="table table-condensed">
        <tbody>
          <tr>
            <td>{this.monthlySpendingLabel()}:</td>
            <td>{this.numberToCurrency(this.props.account.monthlySpendingUsd)}/month</td>
          </tr>

          <tr>
            <td>Business Spending:</td>
            <td>
              {this.businessSpending()}
              <span className="has-ein ">
                {this.businessEinLabel()}
              </span>
            </td>
          </tr>

          <tr>
            <td>Credit Score:</td>
            <td>{this.props.spendingInfo.creditScore}</td>
          </tr>

          <tr>
            <td>Will apply for loan in next 6 months:</td>
            <td>{this.willApplyForLoanLabel()}</td>
          </tr>

          {(() => {
            if (person.readyOn) {
              return (
                <tr>
                  <td>Ready on:</td>
                  <td>{person.readyOn}</td>
                </tr>
              );
            }
          })()}
        </tbody>
      </table>
    );
  },
});

export default SpendingInfo;
