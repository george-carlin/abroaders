const React = require("react");

const HelpBlock = require("../core/HelpBlock");

// The help text that appears above the 'monthly spending' input. The actual
// text depends on whether we're asking the user about one person's spending,
// or both people's. (Note that for a companion account we might still only
// care about one person's spending, if the other is ineligible).
//
// TODO how do we word this? if only one person is eligible, should we still
// ask about the 'combined' spending for both people (since the eligible person
// could theoretically put the ineligible person's spending on his card?)
const MonthlySpendingHelpText = ({firstNames}) => {
  const helpBlocks = [];

  if (firstNames.length > 1) {
    helpBlocks.push(
      <HelpBlock key={0}>
        Please estimate the <b>combined</b> monthly spending
        for {firstNames.join(" and ")} that could be charged to a credit card
        account.
      </HelpBlock>
    );
  } else {
    helpBlocks.push(
      <HelpBlock key={0}>
        What is your average monthly personal spending that could be charged
        to a credit card account?
      </HelpBlock>
    );
  }

  helpBlocks.push(
    <HelpBlock key={1}>
      You should exclude rent, mortage, and car payments unless you are
      certain you can use a credit card as the payment method.
    </HelpBlock>
  );

  return <div>{helpBlocks}</div>;
};

module.exports = MonthlySpendingHelpText;
