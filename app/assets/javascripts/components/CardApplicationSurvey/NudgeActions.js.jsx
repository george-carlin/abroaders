const React = require("react");
const _     = require("underscore");

const Button         = require("../core/Button");
const ButtonGroup    = require("../core/ButtonGroup");
const Form           = require("../core/Form");
const HiddenFieldTag = require("../core/HiddenFieldTag");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const PromptToCallTheBank           = require("./PromptToCallTheBank");

const NudgeActions = React.createClass({
  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
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
    return { currentAction: "initial" };
  },


  setCurrentAction(e, action) {
    e.preventDefault();
    this.setState({currentAction: action});
  },


  render() {
    var buttons, helpText;

    const bankName = this.props.cardAccount.card.bank.name

    var action = "";

    switch (this.state.currentAction) {
      // No helpText or action when state == "initial"
      case "nudged":
      case "heardBack":
        helpText = "What was the outcome?"
        break;
      case "confirmNudgedAndApproved":
        helpText = `You called ${bankName}, and your application is now approved:`
        action = "nudge_and_open";
        break;
      case "confirmNudgedAndDenied":
        helpText = `You called ${bankName}, and found out that your application has been denied:`
        action = "nudge_and_deny";
        break;
      case "confirmNudgedAndPending":
        helpText = `You called ${bankName}, but you still don't know the result of your application:`
        action = "nudge";
        break;
      case "confirmApproved":
        helpText = `${bankName} got back to you, and your application has been approved:`
        action = "open";
        break;
      case "confirmDenied":
        helpText = `${bankName} got back to you, and your application has been denied:`
        action = "deny";
        break;
    };

    if (this.state.currentAction === "initial") {
      buttons = (
        <ButtonGroup>
          <Button
            onClick={e => this.setCurrentAction(e, "nudged")}
            primary
            small
          >
            I called {bankName}
          </Button>
          <Button
            default
            onClick={e => this.setCurrentAction(e, "heardBack")}
            small
          >
            I heard back from {bankName} by mail or email
          </Button>
        </ButtonGroup>
      );
    } else if (_.includes(["nudged", "heardBack"], this.state.currentAction)) {
      let onClickApproved, onClickDenied, onClickPending, pendingText;

      if (this.state.currentAction === "nudged") {
        onClickApproved = e => this.setCurrentAction(e, "confirmNudgedAndApproved");
        onClickDenied   = e => this.setCurrentAction(e, "confirmNudgedAndDenied");
        onClickPending  = e => this.setCurrentAction(e, "confirmNudgedAndPending");
        pendingText     = "I'm still waiting to hear back";
      } else {
        onClickApproved = e => this.setCurrentAction(e, "confirmApproved");
        onClickDenied   = e => this.setCurrentAction(e, "confirmDenied");
      }

      buttons = (
        <ApprovedDeniedPendingBtnGroup
          approvedText="My application was approved"
          deniedText="My application was denied"
          onCancel={e => this.setCurrentAction(e, "initial")}
          onClickApproved={onClickApproved}
          onClickDenied={onClickDenied}
          onClickPending={onClickPending}
          pendingText={pendingText}
        />
      );
    } else {
      // If we get here then the currentAction is one of these:
      // "confirmNudgedAndApproved", "confirmNudgedAndDenied",
      // "confirmNudgedAndPending", "confirmApproved", "confirmDenied",

      let statusOnCancel
      if (_.includes(["confirmApproved", "confirmDenied"], this.state.currentAction)) {
        statusOnCancel = "heardBack";
      } else {
        statusOnCancel = "nudged";
      }

      buttons = (
        <ConfirmOrCancelBtns
          small
          onClickCancel={e => this.setCurrentAction(e, statusOnCancel)}
        />
      );
    }

    return (
      <Form action={this.props.updatePath} method="patch">
        <HiddenFieldTag name="card_account[action]" value={action} />

        <PromptToCallTheBank
          card={this.props.cardAccount.card}
        />

        {(() => {
          if (helpText) {
            return <p>{helpText}</p>;
          }
        })()}

        {buttons}
      </Form>
    );
  },
});

module.exports = NudgeActions;
