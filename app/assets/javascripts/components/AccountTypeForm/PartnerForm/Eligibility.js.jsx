const React = require("react");
const _     = require("underscore");

const HelpBlock  = require("../../core/HelpBlock");
const Radio      = require("../../core/Radio");

const values = ["both", "person_0", "person_1", "neither"];

const Eligibility = React.createClass({
  propTypes: {
    eligibility:      React.PropTypes.oneOf(values),
    onChange:         React.PropTypes.func.isRequired,
    person1FirstName: React.PropTypes.string.isRequired,
    person2FirstName: React.PropTypes.string.isRequired,
  },


  render() {
    const labels = {
      both: `Both ${this.props.person1FirstName} and ${this.props.person2FirstName} are eligible.`,
      person_0: `Only ${this.props.person1FirstName} is eligible.`,
      person_1: `Only ${this.props.person2FirstName} is eligible.`,
      neither:  "Neither of us is eligible.",
    }

    return (
      <div>
        <HelpBlock>
          Are you and your partner eligible to apply for credit cards issued by
          banks in the United States?
        </HelpBlock>

        <HelpBlock>
          You generally need to be either a U.S. citizen or a permanent
          resident to be approved for cards issued by U.S. Banks.
        </HelpBlock>

        {(() => {
          return _.map(values, (value, i) => {
            return (
              <Radio
                attribute="eligibility"
                checked={this.props.eligibility === value}
                className="partner_account_eligibility"
                key={i}
                labelText={labels[value]}
                modelName="partner_account"
                onChange={this.props.onChange}
                value={value}
              />
            );
          });
        })()}
      </div>
    );
  }
});

Eligibility.values = values;

module.exports = Eligibility;
