const React = require("react");
const _     = require("underscore");

const Button         = require("../core/Button");
const ButtonGroup    = require("../core/ButtonGroup");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const ICalledButton                 = require("./ICalledButton");
const IHeardBackButton              = require("./IHeardBackButton");
const PromptToCallTheBank           = require("./PromptToCallTheBank");

const NudgeActions = React.createClass({
  propTypes: {
    cardAccount:  React.PropTypes.object.isRequired,
    submitAction: React.PropTypes.func.isRequired,
  },

  getInitialState() {
    // Possible currentActions:
    // - initial
    // - nudged
    // - heardBack
    // - confirmNudgedAndApproved
    // - confirmNudgedAndDenied
    // - confirmNudgedAndPending
    // - confirmApproved
    // - confirmDenied
    return { currentState: "initial" };
  },


  getAction() {
    switch (this.state.currentState) {
      case "confirmNudgedAndApproved":
        return "nudge_and_open";
      case "confirmNudgedAndDenied":
        return "nudge_and_deny";
      case "confirmNudgedAndPending":
        return "nudge";
      case "confirmApproved":
        return "open";
      case "confirmDenied":
        return "deny";
      default:
        throw "this should never happen";
    }
  },


  getHelpText() {
    const bankName = this.bankName();
    let text;
    switch (this.state.currentState) {
      case "initial":
        text = null;
        break;
      case "nudged":
      case "heardBack":
        text = "What was the outcome?";
        break;
      case "confirmNudgedAndApproved":
        text = `You called ${bankName}, and your application is now approved:`;
        break;
      case "confirmNudgedAndDenied":
        text = `You called ${bankName}, and found out that your application has been denied:`;
        break;
      case "confirmNudgedAndPending":
        text = `You called ${bankName}, but you still don't know the result of your application:`;
        break;
      case "confirmApproved":
        text = `${bankName} got back to you, and your application has been approved:`;
        break;
      case "confirmDenied":
        text = `${bankName} got back to you, and your application has been denied:`;
        break;
      default:
        throw "this should never happen";
    }
    if (text) {
      return <p>{text}</p>;
    } else {
      return null;
    }
  },


  setStateToApproved() {
    this.setState({currentState: "confirmApproved"});
  },


  setStateToDenied() {
    this.setState({currentState: "confirmDenied"});
  },


  setStateToHeardBack() {
    this.setState({currentState: "heardBack"});
  },


  setStateToInitial() {
    this.setState({currentState: "initial"});
  },


  setStateToNudged() {
    this.setState({currentState: "nudged"});
  },


  setStateToNudgedAndApproved() {
    this.setState({currentState: "confirmNudgedAndApproved"});
  },


  setStateToNudgedAndDenied() {
    this.setState({currentState: "confirmNudgedAndDenied"});
  },


  setStateToNudgedAndPending() {
    this.setState({currentState: "confirmNudgedAndPending"});
  },


  submitAction() {
    this.props.submitAction(this.getAction());
  },


  bankName() {
    return this.props.cardAccount.card.bank.name;
  },


  render() {
    return (
      <div>
        <PromptToCallTheBank card={this.props.cardAccount.card} />

        {this.getHelpText()}

        {(() => {
          if (this.state.currentState === "initial") {
            return (
              <ButtonGroup>
                <ICalledButton
                  bankName={this.bankName()}
                  onClick={this.setStateToNudged}
                />
                <IHeardBackButton
                  bankName={this.bankName()}
                  onClick={this.setStateToHeardBack}
                />
              </ButtonGroup>
            );
          } else if (_.includes(["nudged", "heardBack"], this.state.currentState)) {
            let onClickApproved, onClickDenied, onClickPending, pendingText;

            if (this.state.currentState === "nudged") {
              onClickApproved = this.setStateToNudgedAndApproved;
              onClickDenied   = this.setStateToNudgedAndDenied;
              onClickPending  = this.setStateToNudgedAndPending;
              pendingText     = "I'm still waiting to hear back";
            } else {
              onClickApproved = this.setStateToApproved;
              onClickDenied   = this.setStateToDenied;
            }

            return (
              <ApprovedDeniedPendingBtnGroup
                approvedText="My application was approved"
                deniedText="My application was denied"
                onCancel={this.setStateToInitial}
                onClickApproved={onClickApproved}
                onClickDenied={onClickDenied}
                onClickPending={onClickPending}
                pendingText={pendingText}
              />
            );
          } else {
            // If we get here then the currentState is one of these:
            // "confirmNudgedAndApproved", "confirmNudgedAndDenied",
            // "confirmNudgedAndPending", "confirmApproved", "confirmDenied",

            let onClickCancel;
            if (_.includes(["confirmApproved", "confirmDenied"], this.state.currentState)) {
              onClickCancel = this.setStateToHeardBack;
            } else {
              onClickCancel = this.setStateToNudged;
            }

            return (
              <ConfirmOrCancelBtns
                onClickCancel={onClickCancel}
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

module.exports = NudgeActions;
