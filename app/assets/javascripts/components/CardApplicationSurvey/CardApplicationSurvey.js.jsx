const React = require("react");

const ApplyActions     = require("../CardAccountApplyActions");
const CallActions      = require("../CardAccountCallActions");
const NudgeActions     = require("../CardAccountNudgeActions");
const PostCallActions  = require("../CardAccountPostCallActions");
const PostNudgeActions = require("../CardAccountPostNudgeActions");

const CardApplicationSurvey = React.createClass({

  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
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
      if (cardAccount.calledAt) {
        return PostCallActions;
      } else {
        return CallActions;
      }
    } else {
      if (cardAccount.nudgedAt)  {
        return PostNudgeActions;
      } else {
        return NudgeActions;
      }
    }
  },

  render() {
    return React.createElement(
      this.getActionsComponent(),
      {
        cardAccount: this.props.cardAccount,
        updatePath:  this.props.updatePath
      }
    );
  },
});

module.exports = CardApplicationSurvey;
