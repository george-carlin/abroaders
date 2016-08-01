const React = require("react");
const _     = require("underscore");
const humps = require("humps");
const $     = require("jquery");

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
  },

  getInitialState() {
    return {
      cardAccount: this.props.cardAccount,
      isLoading:   false,
    };
  },


  // Return the component that contains the actions for this card account.
  // Note that for some card accounts, no further action is required.
  getActionsComponent() {
    const cardAccount = this.state.cardAccount;

    if (cardAccount.openedAt || cardAccount.redeniedAt) {
      return "noscript";
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


  submitAction(action, extraData) {
    const data = {
      _method: "patch",
      "card_account[action]" : action,
    };

    if (action === "open" && extraData && extraData.openedAt) {
      data["card_account[opened_at]"] = extraData.openedAt;
    }

    this.setState({isLoading: true});

    $.post(
      `/api/v1/card_recommendations/${this.props.cardAccount.id}`,
      data,
      (newCardAccountAttrs, textStatus, jqXHR) => {
        this.setState({isLoading: false});
        const oldCardAccount = this.state.cardAccount;
        const newAttrs       = humps.camelizeKeys(newCardAccountAttrs);
        this.setState({ cardAccount: _.assign(oldCardAccount, newAttrs) });
      }
    );
  },


  render() {
    const actions = React.createElement(
      this.getActionsComponent(),
      {
        applyPath:    this.props.applyPath,
        cardAccount:  this.props.cardAccount,
        declinePath:  this.props.declinePath,
        submitAction: this.submitAction,
      }
    );

    return (
      <div className="CardApplicationSurvey">
        {actions}

        {(() => {
          if (this.state.isLoading) {
            return <div className="LoadingSpinner" />;
          }
        })()}
      </div>
    );
  },
});

module.exports = CardApplicationSurvey;
