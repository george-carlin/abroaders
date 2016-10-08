import React from "react";
import _     from "underscore";
import humps from "humps";
import $     from "jquery";

const Alert = require("../core/Alert");

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
      ajaxStatus:  null,
    };
  },


  componentDidMount() {
    this.authenticityToken = $("meta[name='csrf-token']").prop("content");
  },


  // Return the component that contains the actions for this card account.
  // Note that for some card accounts, no further action is required.
  getActionsComponent() {
    const cardAccount = this.state.cardAccount;

    if (!cardAccount.recommendedAt || cardAccount.openedAt || cardAccount.redeniedAt) {
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
      authenticity_token: this.authenticityToken,
    };

    if (action === "open" && extraData && extraData.openedAt) {
      data["card_account[opened_at]"] = extraData.openedAt;
    }

    $.post(
      `/card_recommendations/${this.props.cardAccount.id}`,
      data,
      (response, textStatus, jqXHR) => {
        if (response.error) {
          this.setState({
            ajaxStatus: "error",
            ajaxError:  response.message,
          });
        } else {
          const oldCardAccount = this.state.cardAccount;
          // 'response' is the updated attributes of the card account
          const newAttrs       = humps.camelizeKeys(response);
          this.setState({
            cardAccount: _.assign(oldCardAccount, newAttrs),
            ajaxStatus:  "done",
          });
        }
      }
    );

    this.setState({ ajaxStatus: "loading"});
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
          switch (this.state.ajaxStatus) {
            case "loading":
              return <div className="LoadingSpinner" />;
            case "done":
              return <ExpiringText text="Saved!" />;
            case "error":
              return <Alert danger >{this.state.ajaxError}</Alert>;
          }
        })()}

      </div>
    );
  },
});

module.exports = CardApplicationSurvey;
