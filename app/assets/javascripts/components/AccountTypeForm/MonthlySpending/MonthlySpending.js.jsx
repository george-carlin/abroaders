const React = require("react");

const Alert       = require("../../core/Alert");
const FormGroup   = require("../../core/FormGroup");
const InputGroup  = require("../../core/InputGroup");
const NumberField = require("../../core/NumberField");

const HelpText = require("./HelpText");

const MonthlySpending = React.createClass({
  propTypes: {
    isSoloPlan:      React.PropTypes.bool,
    modelName:       React.PropTypes.string.isRequired,
    monthlySpending: React.PropTypes.number,
    namesOfEligiblePeople: React.PropTypes.array.isRequired,
    onChange:  React.PropTypes.func.isRequired,
    showError: React.PropTypes.bool,
  },


  showField() {
    return !!this.props.namesOfEligiblePeople.length;
  },


  render() {
    return (
      <div>
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

        <HelpText
          isSoloPlan={this.props.isSoloPlan}
          namesOfEligiblePeople={this.props.namesOfEligiblePeople}
        />

        {(() => {
          if (this.showField()) {
            return (
              <FormGroup>
                <InputGroup
                  addonBefore="$"
                >
                  <NumberField
                    attribute="monthly_spending_usd"
                    min="0"
                    modelName={this.props.modelName}
                    monthlySpending={this.props.monthlySpending}
                    placeholder="Estimated monthly spending"
                    onChange={this.props.onChange}
                  />
                </InputGroup>
              </FormGroup>
            );
          }
        })()}
      </div>
    );
  },
});

module.exports = MonthlySpending;
