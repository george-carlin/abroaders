const React = require("react");

const HelpBlock = require("../../../core/HelpBlock");

const values = require("../Eligibility").values;

const MonthlySpendingHelpText = React.createClass({
  propTypes: {
    eligibility:      React.PropTypes.oneOf(values),
    person0FirstName: React.PropTypes.string.isRequired,
    person1FirstName: React.PropTypes.string.isRequired,
  },


  getNames() {
    switch (this.props.eligibility) {
      case "both":
        return `${this.props.person0FirstName} and ${this.props.person1FirstName}`;
      case "person_0":
        return this.props.person0FirstName;
      case "person_1":
        return this.props.person1FirstName;
      default:
        return null;
    }
  },


  render() {
    if (this.props.eligibility === "neither") {
      return (
        <HelpBlock>
          At this time, we are only able to recommend cards issued by banks
          in the United States. Don't worry, there are still tons of other
          opportunities to reduce the cost of travel.
        </HelpBlock>
      );
    }

    const names = this.getNames();

    return (
      <div>
        {(() => {
          if (!(this.props.eligibility === "both")) {
            return (
              <HelpBlock>
                At this time, we are only able to recommend cards issued by banks
                in the United States. Only {names} will receive credit card
                recommendations, but we'll use your combined spending to make
                sure you earn points as fast as possible.
              </HelpBlock>
            );
          }
        })()}

        <HelpBlock>
          Please estimate the combined monthly spending for {names} that
          could be charged to a credit card account.
        </HelpBlock>

        <HelpBlock>
          You should exclude rent, mortage, and car payments unless you
          are certain you can use a credit card as the payment method.
        </HelpBlock>
      </div>
    );
  },

});

module.exports = MonthlySpendingHelpText;
