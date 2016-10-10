import React from "react";

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const ICalledButton                 = require("./ICalledButton");
const PromptToCallTheBank           = require("./PromptToCallTheBank");

const CallActions = React.createClass({
  propTypes: {
    cardAccount:  React.PropTypes.object.isRequired,
    submitAction: React.PropTypes.func.isRequired,
  },


  getInitialState() {
    return { currentState: "initial" };
    // States:
    // "initial", "called", "confirmApproved", "confirmPending", "confirmDenied"
  },


  getAction() {
    switch (this.state.currentState) {
      case "confirmApproved":
        return "call_and_open";
      case "confirmDenied":
        return "call_and_deny";
      case "confirmPending":
        return "call";
      default:
        throw "this should never happen";
    }
  },


  getHelpText() {
    switch (this.state.currentState) {
      case "initial":
        return `Please let us know when you've called ${this.bankName()}:`;
      case "called":
        return "What was the outcome?";
      case "confirmApproved":
        return "You were approved after calling for reconsideration:";
      case "confirmDenied":
        return "You called for reconsideration, but your application is still denied:";
      case "confirmPending":
        return "Your application is being reconsidered, and you're waiting to hear back:";
    }
  },


  setStateToApproved() {
    this.setState({currentState: "confirmApproved"});
  },


  setStateToCalled() {
    this.setState({currentState: "called"});
  },


  setStateToCancel() {
    this.setState({currentState: "called"});
  },


  setStateToDenied() {
    this.setState({currentState: "confirmDenied"});
  },


  setStateToPending() {
    this.setState({currentState: "confirmPending"});
  },


  submitAction() {
    this.props.submitAction(this.getAction());
  },


  bankName() {
    return this.props.cardAccount.card.bank.name;
  },


  phoneNumber() {
    const bank = this.props.cardAccount.card.bank;
    if (this.props.cardAccount.card.bp === "personal") {
      return bank.personalPhone;
    } else {
      return bank.businessPhone;
    }
  },


  render() {
    let buttons, helpText;

    return (
      <div>
        <PromptToCallTheBank
          card={this.props.cardAccount.card}
          reconsideration
        />

        <p>{this.getHelpText()}</p>

        {(() => {
          switch (this.state.currentState) {
            case "initial":
              return (
                <ICalledButton
                  bankName={this.bankName()}
                  onClick={this.setStateToCalled}
                />
              );
            case "called": {
              const pendingText = "I'm being reconsidered, but waiting to hear" +
                                  " back about whether it was successful";
              return (
                <ApprovedDeniedPendingBtnGroup
                  approvedText="I was approved after reconsideration"
                  deniedText="My application is still denied"
                  onClickApproved={this.setStateToApproved}
                  onClickDenied={this.setStateToDenied}
                  onClickPending={this.setStateToPending}
                  pendingText={pendingText}
                />
              );
            }
            case "confirmApproved":
            case "confirmDenied":
            case "confirmPending":
              return (
                <ConfirmOrCancelBtns
                  onClickCancel={this.setStateToCalled}
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

module.exports = CallActions;
