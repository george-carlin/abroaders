import React from "react";
import _     from "underscore";

import HelpBlock from "../../core/HelpBlock";

const HelpText = React.createClass({
  propTypes: {
    isSoloPlan:            React.PropTypes.bool,
    namesOfEligiblePeople: React.PropTypes.array.isRequired,
  },


  render() {
    const blocks = [];
    const names  = this.props.namesOfEligiblePeople.join(" and ");

    switch (this.props.namesOfEligiblePeople.length) {
      case 0:
        blocks.push(
          "At this time, we are only able to recommend cards issued by banks " +
          "in the United States. Don't worry, there are still tons of other " +
          "opportunities to reduce the cost of travel."
        );
        break;
      case 1:
        if (this.props.isSoloPlan) {
          blocks.push(
            "What is your average monthly spending that could be charged to " +
            "a credit card account?"
          );
        } else {
          blocks.push(
            "At this time, we are only able to recommend cards issued by banks " +
            `in the United States. Only ${names} will receive credit card ` +
            "recommendations, but we'll use your combined spending to make " +
            "sure you earn points as fast as possible."
          );
          blocks.push(
            `Please estimate the combined monthly spending for ${names} that ` +
            "could be charged to a credit card account."
          );
        }
        blocks.push(
          "You should exclude rent, mortage, and car payments unless you " +
          "are certain you can use a credit card as the payment method."
        );
        break;
      case 2:
        blocks.push(
          `Please estimate the combined monthly spending for ${names} ` +
          "that could be charged to a credit card account."
        );

        blocks.push(
          "You should exclude rent, mortage, and car payments unless you " +
          "are certain you can use a credit card as the payment method."
        );
        break;
    }


    return (
      <div>
        {(() => {
          return _.map(blocks, (blockText, i) => {
            return <HelpBlock key={i}>{blockText}</HelpBlock>;
          });
        })()}
      </div>
    );
  },

});

module.exports = HelpText;
