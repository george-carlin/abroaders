import React from "react";
import $     from "jquery";
import humps from "humps";

import Button              from "../../../../core/Button";
import ConfirmOrCancelBtns from "../../../../ConfirmOrCancelBtns";

const OfferRow = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    offer: React.PropTypes.object.isRequired,
    addOfferCallback: React.PropTypes.func.isRequired,
  },

  componentWillMount() {
    this.changeStateIfExists(this.props);
  },

  componentDidMount() {
    this.authenticityToken = $("meta[name='csrf-token']").prop("content");
  },

  componentWillReceiveProps(nextProps) {
    this.changeStateIfExists(nextProps);
  },

  setStateToInitial() {
    this.setState({currentState: "initial"});
  },

  setStateToRecommended() {
    this.setState({currentState: "recommended"});
  },

  setStateToApplied() {
    this.setState({currentState: "applied"});
  },

  submitAction() {
    const data = {
      "card_recommendation[offer_id]": this.props.offer.id,
      authenticity_token: this.authenticityToken,
    };

    $.post(
      `/admin/people/${this.props.person.id}/card_recommendations`,
      data,
      (response) => {
        const cardAccount = humps.camelizeKeys(response);
        this.props.person.cardAccounts.push(cardAccount);
        this.props.addOfferCallback(cardAccount);
        this.setStateToApplied();
      },
      "json"
    );
  },

  changeStateIfExists(props) {
    const cardAccounts      = props.person.cardAccounts;
    const offer             = props.offer;
    const findedCardAccount = cardAccounts.find((cardAccount) => {
      return cardAccount.offerId === offer.id;
    });

    if (typeof(findedCardAccount) !== "undefined") {
      this.setStateToApplied();
    } else {
      this.setStateToInitial();
    }
  },

  render() {
    const offer = this.props.offer;

    return (
      <tr>
        <td>{offer.identifier}</td>
        <td>Points: {offer.pointsAwarded}</td>
        <td>Spend: {offer.spend}</td>
        <td>Cost: {offer.cost}</td>
        <td>Days: {offer.days}</td>
        <td className="link-td">
          <a href={offer.link} rel="nofollow" target="_blank">Link</a>
        </td>
        <td>
          {(() => {
            switch (this.state.currentState) {
              case "initial":
                return (
                  <Button
                    tiny
                    primary
                    onClick={this.setStateToRecommended}
                  >
                    Recommend
                  </Button>
                );
              case "recommended":
                return (
                  <ConfirmOrCancelBtns
                    cancelBtnClass="btn-xs"
                    confirmBtnClass="btn-xs"
                    onClickCancel={this.setStateToInitial}
                    onClickConfirm={this.submitAction}
                  />
                );
              case "applied":
                return (
                  <Button
                    className="disabled"
                    tiny
                    success
                  >
                    Recommended!
                  </Button>
                );
            }
          })()}
        </td>
      </tr>
    );
  },
});

export default OfferRow;
