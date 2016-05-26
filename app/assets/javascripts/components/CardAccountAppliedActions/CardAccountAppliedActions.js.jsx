const React = require("react");
const $     = require("jquery");

const ApproveCardAccountFormFields = require("../ApproveCardAccountFormFields");
const Button                       = require("../Button");
const ConfirmOrCancelBtns          = require("../ConfirmOrCancelBtns");
const Form                         = require("../Form");

const CardAccountAppliedActions = React.createClass({
  propTypes: {
    updatePath:         React.PropTypes.string.isRequired,
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
    var buttons, helpText, action;

    // TODO: automatically camelize attributes before passing them in to the React Componeny
    const recommendedAt = new Date(this.props.cardAccount.recommended_at);
    const today = new Date();

    recommendedAt.setHours(0,0,0,0);
    today.setHours(0,0,0,0);

    const askForApprovalDate = recommendedAt < today;

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
          <div className="btn-group">
            <Button
              small
              primary
              onClick={e => this.setCurrentAction(e, "confirmApproved")}
            >
              I was approved
            </Button>
            <Button
              small
              default
              onClick={e => this.setCurrentAction(e, "confirmDenied")}
            >
              My application was denied
            </Button>
            <Button
              small
              default
              onClick={e => this.setCurrentAction(e, "confirmPending")}
            >
              I'm waiting to hear back
            </Button>
          </div>
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
        <p>{helpText}</p>

        <Form action={this.props.updatePath} method="patch">
          <input type="hidden" name="card_account[action]" value={action} />
          {buttons}
        </Form>
      </div>
    );
  }

});

module.exports = CardAccountAppliedActions;