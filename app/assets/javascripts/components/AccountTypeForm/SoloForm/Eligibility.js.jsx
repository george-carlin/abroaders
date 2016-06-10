const React = require("react");

const Radio     = require("../../core/Radio");
const HelpBlock = require("../../core/HelpBlock");

const Eligibility = React.createClass({
  propTypes: {
    isEligibleToApply: React.PropTypes.bool.isRequired,
    onChange:          React.PropTypes.func.isRequired,
  },

  render() {
    return (
      <div className="Eligibility">
        <HelpBlock>
          Are you eligible to apply for credit cards issued by banks in the
          United States?
        </HelpBlock>

        <HelpBlock>
          You generally need to be either a U.S. citizen or a permanent
          resident to be approved for cards issued by U.S. Banks.
        </HelpBlock>

        <Radio
          attribute="eligible_to_apply"
          checked={this.props.isEligibleToApply}
          className="solo_account_eligible_to_apply"
          labelText="Yes - I am eligible"
          modelName="solo_account"
          onChange={() => this.props.onChange(true) }
          value="true"
        />

        <Radio
          attribute="eligible_to_apply"
          checked={!this.props.isEligibleToApply}
          className="solo_account_eligible_to_apply"
          labelText="No - I am not eligible"
          modelName="solo_account"
          onChange={() => this.props.onChange(false) }
          value="false"
        />
      </div>
    );
  },
});

module.exports = Eligibility;
