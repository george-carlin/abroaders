import React from "react";
import _     from "underscore";
import humps from "humps";
import $     from "jquery";

import ApplyActions     from "./ApplyActions";
import CallActions      from "./CallActions";
import ExpiringText     from "./ExpiringText";
import NudgeActions     from "./NudgeActions";
import PostCallActions  from "./PostCallActions";
import PostNudgeActions from "./PostNudgeActions";

const CardApplicationSurvey = React.createClass({
  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
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

    if (!cardAccount.recommendedAt || cardAccount.openedOn || cardAccount.redeniedAt) {
      return "noscript";
    }

    if (!cardAccount.appliedOn) {
      return ApplyActions;
    }

    if (cardAccount.deniedAt) {
      return cardAccount.calledAt ? PostCallActions : CallActions;
    } else {
      return cardAccount.nudgedAt ? PostNudgeActions : NudgeActions;
    }
  },

  submitAction(action, extraData) {
    const wrapperId = `#card_recommendation_${this.props.cardAccount.id}`;
    $(`${wrapperId} .card_recommendation_apply_decline_btn_group`).remove();

    const data = {
      _method: "patch",
      "card[action]" : action,
      authenticity_token: this.authenticityToken,
    };

    if (action === "open" && extraData && extraData.openedOn) {
      data["card[opened_on]"] = extraData.openedOn;
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
    const cardAccount = _.clone(this.props.cardAccount);
    // The prop is called 'card' for legacy reasons:
    cardAccount.card = cardAccount.cardProduct;
    const actions = React.createElement(
      this.getActionsComponent(),
      {
        cardAccount,
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
              return <div className="alert alert-danger" role="alert">{this.state.ajaxError}</div>;
          }
        })()}

      </div>
    );
  },
});

module.exports = CardApplicationSurvey;
