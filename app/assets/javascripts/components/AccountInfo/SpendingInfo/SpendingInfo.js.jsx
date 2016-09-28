const React = require("react");

const SpendingInfo = React.createClass({
  propTypes: {
    spendingInfo: React.PropTypes.object.isRequired,
    account: React.PropTypes.object.isRequired
  },

  numberToCurrency(number) {
    return number.toLocaleString("en-US", { style: "currency", currency: "USD" });
  },

  monthlySpendingLabel() {
    return (this.hasCompanion() == true ? "Shared" : "Personal") + " spending";
  },

  willApplyForLoanLabel() {
    return this.props.spendingInfo.willApplyForLoan == true ? "Yes" : "No";
  },

  hasCompanion() {
    return !!this.props.account.companion;
  },

  hasBusiness() {
    return (this.props.spendingInfo.hasBusiness != "no_business");
  },

  businessEinLabel() {
    if (this.hasBusiness()) {
      if (this.props.spendingInfo.hasBusiness == "with_ein") {
        return "(Has EIN)";
      }
      else {
        return "(Does not have EIN)";
      }
    }
  },

  businessSpending() {
    if (this.hasBusiness()) {
      return this.numberToCurrency(this.props.spendingInfo.businessSpendingUsd);
    }
    else {
      return "No business";
    }
  },

  render() {
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
        </tbody>
      </table>
    );
  }
});

module.exports = SpendingInfo;
