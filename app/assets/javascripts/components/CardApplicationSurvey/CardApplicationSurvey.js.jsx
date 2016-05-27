const React = require("react");

const CardAccountAppliedActions = require("../CardAccountAppliedActions");
const CardAccountDeniedActions  = require("../CardAccountDeniedActions");
const CardAccountNudgeActions   = require("../CardAccountNudgeActions");
const CardAccountPostNudgeActions  = require("../CardAccountPostNudgeActions");
const CardAccountReconsiderActions = require("../CardAccountReconsiderActions");

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
      return CardAccountAppliedActions;
    }

    if (cardAccount.deniedAt) {
      if (cardAccount.calledAt) {
        return CardAccountReconsiderActions;
      } else {
        return CardAccountDeniedActions;
      }
    } else {
      if (cardAccount.nudgedAt)  {
        return CardAccountPostNudgeActions;
      } else {
        return CardAccountNudgeActions;
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
