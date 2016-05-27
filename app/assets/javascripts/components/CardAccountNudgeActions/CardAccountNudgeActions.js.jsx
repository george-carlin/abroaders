const React = require("react");

const Button              = require("../Button");
const ButtonGroup         = require("../ButtonGroup");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");
const Form                = require("../Form");

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

    switch (this.state.currentAction) {
      case "initial":
        helpText = "Please let us know when you've called the bank. If the " +
                "bank got back to you before you could call them, tell us too:"
        break;
      case "nudged":
        helpText = "How did it go?"
        break;
      case "heardBack":
        helpText = "What did the bank say?"
        break;
      case "confirmNudgedAndApproved":
        helpText = "You called the bank, and your application is now approved:"
        action = "nudge_and_open";
        break;
      case "confirmNudgedAndDenied":
        helpText = "You called the bank, and found out that your application has been denied:"
        action = "nudge_and_deny";
        break;
      case "confirmNudgedAndPending":
        helpText = "You called the bank, but you still don't know the result of your application:"
        action = "nudge";
        break;
      case "confirmApproved":
        helpText = "The bank got back to you, and your application has been approved:"
        action = "open";
        break;
      case "confirmDenied":
        helpText = "The bank got back to you, and your application has been denied:"
        action = "deny";
        break;
    };

    switch (this.state.currentAction) {
      case "initial":
        buttons = (
          <ButtonGroup>
            <Button
              small
              primary
              onClick={e => this.setCurrentAction(e, "nudged")}
            >
              I called
            </Button>
            <Button
              small
              default
              onClick={e => this.setCurrentAction(e, "heardBack")}
            >
              The bank got back to me before I could call them
            </Button>
          </ButtonGroup>
        );
        break;
      case "nudged":
        buttons = (
          <div>
            <ButtonGroup>
              <Button
                small
                primary
                onClick={e => this.setCurrentAction(e, "confirmNudgedAndApproved")}
              >
                My application was approved
              </Button>
              <Button
                small
                default
                onClick={e => this.setCurrentAction(e, "confirmNudgedAndDenied")}
              >
                My application was denied
              </Button>
              <Button
                small
                default
                onClick={e => this.setCurrentAction(e, "confirmNudgedAndPending")}
              >
                I'm still waiting to hear back
              </Button>
            </ButtonGroup>
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
            <ButtonGroup>
              <Button
                small
                primary
                onClick={e => this.setCurrentAction(e, "confirmApproved")}
              >
                My application was approved
              </Button>
              <Button
                small
                default
                onClick={e => this.setCurrentAction(e, "confirmDenied")}
              >
                My application was denied
              </Button>
            </ButtonGroup>
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

    const bank = this.props.cardAccount.card.bank
    var   phoneNumber;
    if (this.props.cardAccount.card.bp === "personal") {
      phoneNumber = bank.personalPhone;
    } else {
      phoneNumber = bank.businessPhone;
    }

    return (
      <Form action={this.props.updatePath} method="patch">
        <input type="hidden" name="card_account[action]" value={action} />

        <p>
          We strongly recommend that you
          call {bank.name} at {phoneNumber} as soon as possible to ask for a
          real person to review your application by phone.
        </p>

        <p>
          You’re more than twice as likely to get approved if you
          call {bank.name} than if you wait for them to send your decision in
          the mail
        </p>

        <p>{helpText}</p>

        {buttons}
      </Form>
    );
  },
});

module.exports = CardAccountNudgeActions;
