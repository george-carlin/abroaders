const React = require("react");

const Button    = require("../../core/Button");
const HelpBlock = require("../../core/HelpBlock");

const PhoneNumber     = require("../PhoneNumber");

const Eligibility     = require("./Eligibility");
const MonthlySpending = require("./MonthlySpending");

const Step1 = React.createClass({
  propTypes: {
    isEligibleToApply:        React.PropTypes.bool.isRequired,
    monthlySpending:          React.PropTypes.number,
    onChangeEligibility:      React.PropTypes.func.isRequired,
    onChangeMonthlySpending:  React.PropTypes.func.isRequired,
    showMonthlySpendingError: React.PropTypes.bool,
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

        {(() => {
          if (this.props.isEligibleToApply) {
            return (
              <div>
                <MonthlySpending
                  modelName={modelName}
                  monthlySpending={this.props.monthlySpending}
                  onChange={this.props.onChangeMonthlySpending}
                  showError={this.props.showMonthlySpendingError}
                />
              </div>
            );
          } else {
            return (
              <HelpBlock>
                At this time, we are only able to recommend cards issued by
                banks in the United States. Don't worry, there are still tons
                of other opportunities to reduce the cost of travel.
              </HelpBlock>
            );
          }
        })()}

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

module.exports = Step1;
