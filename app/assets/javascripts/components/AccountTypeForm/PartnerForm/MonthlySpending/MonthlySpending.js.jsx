const React = require("react");

const Alert       = require("../../../core/Alert");
const FormGroup   = require("../../../core/FormGroup");
const InputGroup  = require("../../../core/InputGroup");
const NumberField = require("../../../core/NumberField");

const values = require("../Eligibility").values;

const HelpText = require("./HelpText");

const MonthlySpending = React.createClass({
  propTypes: {
    eligibility:      React.PropTypes.oneOf(values),
    onChange:         React.PropTypes.func.isRequired,
    modelName:        React.PropTypes.string.isRequired,
    person0FirstName: React.PropTypes.string.isRequired,
    person1FirstName: React.PropTypes.string.isRequired,
    showError:        React.PropTypes.bool,
  },


  render() {
    return (
      <FormGroup>
        <HelpText
          eligibility={this.props.eligibility}
          person0FirstName={this.props.person0FirstName}
          person1FirstName={this.props.person1FirstName}
        />

        {(() => {
          if (this.props.showError) {
            return (
              <Alert danger >
                Invalid monthly spend. Must be a number greater than
                or equal to 0.
              </Alert>
            );
          }
        })()}

        {(() => {
          if (this.props.eligibility !== "neither") {
            return (
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
            );
          }
        })()}
      </FormGroup>
    );
  },

});

module.exports = MonthlySpending;
