const React = require("react");
const _     = require("underscore");
const humps = require("humps");
const $     = require("jquery");

const ApplyActions     = require("./ApplyActions");
const CallActions      = require("./CallActions");
const ExpiringText     = require("./ExpiringText");
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
      loading:     null,
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

    this.setState({ loading: "loading"});

    $.post(
      `/api/v1/card_recommendations/${this.props.cardAccount.id}`,
      data,
      (newCardAccountAttrs, textStatus, jqXHR) => {
        const oldCardAccount = this.state.cardAccount;
        const newAttrs       = humps.camelizeKeys(newCardAccountAttrs);
        this.setState({
          cardAccount: _.assign(oldCardAccount, newAttrs),
          loading:     "done",
        });
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
          switch (this.state.loading) {
            case "loading":
              return <div className="LoadingSpinner" />;
            case "done":
              return <ExpiringText text="Saved!" />;
          }
        })()}

      </div>
    );
  },
});

module.exports = CardApplicationSurvey;
