const React = require("react");

const ApprovedDeniedPendingBtnGroup = require("../ApprovedDeniedPendingBtnGroup");
const Button              = require("../Button");
const ButtonGroup         = require("../ButtonGroup");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");
const Form                = require("../Form");
const PromptToCallTheBank = require("../PromptToCallTheBank");

const CardAccountNudgeActions = React.createClass({
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
    var buttons, helpText, action;

    const bankName = this.props.cardAccount.card.bank.name

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

    switch (this.state.currentAction) {
      case "initial":
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
        break;
      case "nudged":
        buttons = (
          <div>
            <ApprovedDeniedPendingBtnGroup
              approvedText="My application was approved"
              deniedText="My application was denied"
              onClickApproved={e => this.setCurrentAction(e, "confirmNudgedAndApproved")}
              onClickDenied={e => this.setCurrentAction(e, "confirmNudgedAndDenied")}
              onClickPending={e => this.setCurrentAction(e, "confirmNudgedAndPending")}
              pendingText="I'm still waiting to hear back"
            />
            <Button
              link
              small
              onClick={e => this.setCurrentAction(e, "initial")}
            >
              Cancel
            </Button>
          </div>
        );
        break;
      case "heardBack":
        buttons = (
          <div>
            <ApprovedDeniedPendingBtnGroup
              approvedText="My application was approved"
              deniedText="My application was denied"
              onClickApproved={e => this.setCurrentAction(e, "confirmApproved")}
              onClickDenied={e => this.setCurrentAction(e, "confirmDenied")}
              noPendingBtn
            />
            <Button
              small
              link
              onClick={e => this.setCurrentAction(e, "initial")}
            >
              Cancel
            </Button>
          </div>
        );
        break;
      // Same actions for all 3 of these:
      case "confirmNudgedAndApproved":
      case "confirmNudgedAndDenied":
      case "confirmNudgedAndPending":
        buttons = (
          <ConfirmOrCancelBtns
            small
            onClickCancel={e => this.setCurrentAction(e, "nudged")}
          />
        )
        break;
      // Same actions for both of these:
      case "confirmApproved":
      case "confirmDenied":
        buttons = (
          <ConfirmOrCancelBtns
            small
            onClickCancel={e => this.setCurrentAction(e, "heardBack")}
          />
        )
        break;
    }

    return (
      <Form action={this.props.updatePath} method="patch">
        <input type="hidden" name="card_account[action]" value={action} />

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

module.exports = CardAccountNudgeActions;
