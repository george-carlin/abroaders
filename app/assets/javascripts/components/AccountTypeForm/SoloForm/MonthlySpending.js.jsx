const React = require("react");

const Alert       = require("../../core/Alert");
const FormGroup   = require("../../core/FormGroup");
const InputGroup  = require("../../core/InputGroup");
const HelpBlock   = require("../../core/HelpBlock");
const NumberField = require("../../core/NumberField");

const MonthlySpendingForm = React.createClass({
  propTypes: {
    monthlySpending: React.PropTypes.number,
    onChange:        React.PropTypes.func.isRequired,
    showError:       React.PropTypes.bool,
  },


  render() {
    return (
      <div>
        <FormGroup>
          <HelpBlock>
            What is your average monthly spending that could be charged to
            a credit card account?
          </HelpBlock>

          <HelpBlock>
            You should exclude rent, mortage, and car payments unless you
            are certain you can use a credit card as the payment method.
          </HelpBlock>

          <InputGroup
            addonBefore="$"
          >
            <NumberField
              attribute="monthly_spending_usd"
              min="0"
              modelName="solo_account"
              monthlySpending={this.props.monthlySpending}
              placeholder="Estimated monthly spending"
              onChange={this.props.onChange}
            />
          </InputGroup>
        </FormGroup>

        {(() => {
          if (this.props.showError) {
            return (
              <Alert danger >
                Invalid monthly spend. Must be a number greater than or equal
                to 0.
              </Alert>
            );
          }
        })()}
      </div>
    );
  },
});

module.exports = MonthlySpendingForm;
