const React = require("react");

const Button         = require("../core/Button");
const HiddenFieldTag = require("../core/HiddenFieldTag");
const Form           = require("../core/Form");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const ApproveCardAccountFormFields  = require("./ApproveCardAccountFormFields");
const ApplyOrDeclineBtns            = require("./ApplyOrDeclineBtns");

const ApplyActions = React.createClass({
  propTypes: {
    applyPath:   React.PropTypes.string.isRequired,
    declinePath: React.PropTypes.string.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return {
      currentAction: "initial",
      // States:
      // "initial", "applied", "confirmApproved", "confirmPending", "confirmDenied"
    }
  },

  setCurrentAction(e, action) {
    e.preventDefault();
    this.setState({ currentAction: action });
  },

  render() {
    var buttons, helpText;

    const recommendedAt = new Date(this.props.cardAccount.recommendedAt);
    const today = new Date();

    recommendedAt.setHours(0,0,0,0);
    today.setHours(0,0,0,0);

    const askForApprovalDate = recommendedAt < today;

    var action="";

    switch (this.state.currentAction) {
      case "initial":
        helpText = "When you have applied for the card, please let us know:";
        break;
      case "applied":
        helpText = "Were you approved for the card?";
        break;
      case "confirmApproved":
        action = "open";
        if (askForApprovalDate) {
          helpText = "When were you approved for the card?";
        } else {
          helpText = "The bank approved your card application:";
        }
        break;
      case "confirmDenied":
        helpText = "Your application was denied by the bank:";
        action = "deny";
        break;
      case "confirmPending":
        helpText = "You applied, and you're waiting to hear back from the bank:";
        action = "apply";
        break;
    }

    switch (this.state.currentAction) {
      case "initial":
        buttons = (
          <Button
            small
            primary
            onClick={e => this.setCurrentAction(e, "applied")}
          >
            I applied
          </Button>
        );
        break;
      case "applied":
        buttons = (
          <ApprovedDeniedPendingBtnGroup
            approvedText="I was approved"
            deniedText="My application was denied"
            onClickApproved={e => this.setCurrentAction(e, "confirmApproved")}
            onClickDenied={e => this.setCurrentAction(e, "confirmDenied")}
            onClickPending={e => this.setCurrentAction(e, "confirmPending")}
            pendingText="I'm waiting to hear back"
          />
        );
        break;
      case "confirmApproved":
        buttons = (
          <ApproveCardAccountFormFields
            askForDate={askForApprovalDate}
            onClickCancel={e => this.setCurrentAction(e, "applied")}
            path={this.props.updatePath}
          />
        )
        break;
      case "confirmDenied":
      case "confirmPending":
        buttons = (
          <ConfirmOrCancelBtns onClickCancel={e => this.setCurrentAction(e, "applied")} small />
        );
        break;
    }

    return (
      <div>
        <ApplyOrDeclineBtns
          applyPath={this.props.applyPath}
          declinePath={this.props.declinePath}
        />

        <br />
        <br />

        <p>{helpText}</p>

        <Form action={this.props.updatePath} method="patch">
          <HiddenFieldTag name="card_account[action]" value={action} />
          {buttons}
        </Form>
      </div>
    );
  }

});

module.exports = ApplyActions;
