import React from "react";

import Button from "../core/Button";

import ConfirmOrCancelBtns from "../ConfirmOrCancelBtns";

import ApprovedDeniedPendingBtnGroup from "./ApprovedDeniedPendingBtnGroup";
import ApproveCardAccountFormFields  from "./ApproveCardAccountFormFields";

const ApplyActions = React.createClass({
  propTypes: {
    cardAccount:  React.PropTypes.object.isRequired,
    submitAction: React.PropTypes.func.isRequired,
  },

  getInitialState() {
    return {
      // States:
      // "initial", "applied", "confirmApproved", "confirmPending", "confirmDenied"
      currentState: "initial",
      openedOn: this.formatDate(new Date()),
    };
  },

  setStateToApplied() {
    this.setState({currentState: "applied"});
  },

  setStateToApproved() {
    this.setState({currentState: "confirmApproved"});
  },

  setStateToDenied() {
    this.setState({currentState: "confirmDenied"});
  },

  setStateToPending() {
    this.setState({currentState: "confirmPending"});
  },

  setOpenedAt(openedOn) {
    this.setState({ openedOn });
  },

  getAction() {
    switch (this.state.currentState) {
      case "confirmApproved":
        return "open";
      case "confirmDenied":
        return "deny";
      case "confirmPending":
        return "apply";
      default:
        throw "this should never happen";
    }
  },

  getHelpText() {
    switch (this.state.currentState) {
      case "initial":
        return "When you have applied for the card, please let us know:";
      case "applied":
        return "Were you approved for the card?";
      case "confirmApproved":
        if (this.isRecommendedBeforeToday()) {
          return "When were you approved for the card?";
        } else {
          return "The bank approved your card application:";
        }
      case "confirmDenied":
        return "Your application was denied by the bank:";
      case "confirmPending":
        return "You applied, and you're waiting to hear back from the bank:";
      default:
        throw "this should never happen";
    }
  },

  submitAction() {
    this.props.submitAction(
      this.getAction(),
      { openedOn: this.state.openedOn }
    );
  },

  formatDate(date) {
    const day   = this.formatLeadingZeroes(date.getDate());
    const month = this.formatLeadingZeroes(date.getMonth() + 1);
    const year  = date.getFullYear();

    return month + "/" + day + "/" + year;
  },


  formatLeadingZeroes(num) {
    let numS = num.toString();
    if (numS.length < 2) numS = `0${numS}`;
    return numS;
  },

  isRecommendedBeforeToday() {
    const rAt   = new Date(this.props.cardAccount.recommendedAt);
    const today = new Date();

    // Simply comparing the dates will cause bugs when the system time zone is
    // behind UTC. The below is a quick fix, but this is probably indicative
    // of some kind of deeper problem with how we're dealing with timezones.
    // TODO investigate.
    if (rAt.getUTCFullYear() < today.getUTCFullYear()) {
      return true;
    } else if (rAt.getUTCFullYear() > today.getUTCFullYear()) {
      return false;
    }

    if (rAt.getUTCMonth() < today.getUTCMonth()) {
      return true;
    } else if (rAt.getUTCMonth() > today.getUTCMonth()) {
      return false;
    }

    return rAt.getUTCDate() < today.getUTCDate();
  },

  render() {
    return (
      <div>
        <p>{this.getHelpText()}</p>

        {(() => {
          switch (this.state.currentState) {
            case "initial":
              return (
                <Button
                  small
                  primary
                  onClick={this.setStateToApplied}
                >
                  I applied
                </Button>
              );
            case "applied":
              return (
                <ApprovedDeniedPendingBtnGroup
                  approvedText="I was approved"
                  deniedText="My application was denied"
                  onClickApproved={this.setStateToApproved}
                  onClickDenied={this.setStateToDenied}
                  onClickPending={this.setStateToPending}
                  pendingText="I'm waiting to hear back"
                />
              );
            case "confirmApproved":
              return (
                <ApproveCardAccountFormFields
                  askForDate={this.isRecommendedBeforeToday()}
                  onClickCancel={this.setStateToApplied}
                  openedOn={this.state.openedOn}
                  setOpenedAt={this.setOpenedAt}
                  submitAction={this.submitAction}
                />
              );
            case "confirmDenied":
            case "confirmPending":
              return (
                <ConfirmOrCancelBtns
                  onClickCancel={this.setStateToApplied}
                  onClickConfirm={this.submitAction}
                  small
                />
              );
          }
        })()}
      </div>
    );
  },

});

export default ApplyActions;
