const React = require("react");

const ApplyActions     = require("./ApplyActions");
const CallActions      = require("./CallActions");
const NudgeActions     = require("./NudgeActions");
const PostCallActions  = require("./PostCallActions");
const PostNudgeActions = require("./PostNudgeActions");

const CardApplicationSurvey = React.createClass({

  propTypes: {
    applyPath:   React.PropTypes.string.isRequired,
    cardAccount: React.PropTypes.object.isRequired,
    declinePath: React.PropTypes.string.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  // Return the component that contains the actions for this card account.
  // Note that for some card accounts, no further action is required.
  getActionsComponent() {
    const cardAccount = this.props.cardAccount;

    if (cardAccount.openedAt || cardAccount.redeniedAt) {
      return undefined;
    }

    if (!cardAccount.appliedAt) {
      return ApplyActions;
    }

    if (cardAccount.deniedAt) {
      return cardAccount.calledAt ? PostCallActions : CallActions;
    } else {
      return cardAccount.nudgedAt ? PostNudgeActions : NudgeActions;
    }
  },

  render() {
    return React.createElement(
      this.getActionsComponent(),
      {
        applyPath:   this.props.applyPath,
        cardAccount: this.props.cardAccount,
        declinePath: this.props.declinePath,
        updatePath:  this.props.updatePath
      }
    );
  },
});

module.exports = CardApplicationSurvey;
