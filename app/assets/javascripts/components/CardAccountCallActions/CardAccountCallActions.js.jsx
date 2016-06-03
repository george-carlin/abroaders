const React = require("react");

const ApprovedDeniedPendingBtnGroup = require("../ApprovedDeniedPendingBtnGroup");
const Button              = require("../Button");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");
const Form                = require("../Form");
const HiddenFieldTag      = require("../HiddenFieldTag");
const PromptToCallTheBank = require("../PromptToCallTheBank");

const CardAccountCallActions = React.createClass({
  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  getInitialState() {
    return { currentAction: "initial", }
    // States:
    // "initial", "called", "confirmApproved", "confirmPending", "confirmDenied"
  },


  setCurrentAction(e, action) {
    e.preventDefault();
    this.setState({currentAction: action});
  },


  render() {
    let buttons, helpText;

    const bankName = this.props.cardAccount.card.bank.name

    var action = "";

    switch (this.state.currentAction) {
      case "initial":
        helpText = `Please let us know when you've called ${bankName}:`
        break;
      case "called":
        helpText = "What was the outcome?"
        break;
      case "confirmApproved":
        action = "call_and_open";
        helpText = "You were approved after calling for reconsideration:"
        break;
      case "confirmDenied":
        helpText = "You called for reconsideration, but your application is still denied:"
        action = "call_and_deny";
        break;
      case "confirmPending":
        helpText = "Your application is being reconsidered, and you're waiting to hear back:"
        action = "call";
        break;
    }

    switch (this.state.currentAction) {
      case "initial":
        buttons = (
          <Button
            primary
            small
            onClick={e => this.setCurrentAction(e, "called")}
          >
            I called {bankName}
          </Button>
        );
        break;
      case "called":
        buttons = (
          <ApprovedDeniedPendingBtnGroup
            approvedText="I was approved after reconsideration"
            deniedText="My application is still denied"
            onClickApproved={e => this.setCurrentAction(e, "confirmApproved")}
            onClickDenied={e => this.setCurrentAction(e, "confirmDenied")}
            onClickPending={e => this.setCurrentAction(e, "confirmPending")}
            pendingText="I'm being reconsidered, but waiting to hear back about whether it was successful"
          />
        )
        break;
      case "confirmApproved":
      case "confirmDenied":
      case "confirmPending":
        buttons = (
          <ConfirmOrCancelBtns
            onClickCancel={e => this.setCurrentAction(e, "called")}
            small
          />
        )
        break;
    }

    const bank = this.props.cardAccount.card.bank
    var   phoneNumber;
    if (this.props.cardAccount.card.bp === "personal") {
      phoneNumber = bank.personalPhone;
    } else {
      phoneNumber = bank.businessPhone;
    }

    return (
      <Form action={this.props.updatePath} method="patch">
        <HiddenFieldTag name="card_account[action]" value={action} />

        <PromptToCallTheBank
          card={this.props.cardAccount.card}
          reconsideration
        />

        <p>{helpText}</p>

        {buttons}
      </Form>
    );
  },
});

module.exports = CardAccountCallActions;
