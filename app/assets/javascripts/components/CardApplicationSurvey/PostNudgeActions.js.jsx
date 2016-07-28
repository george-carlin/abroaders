const React = require("react");

const Button         = require("../core/Button");
const ButtonGroup    = require("../core/ButtonGroup");
const Form           = require("../core/Form");
const HiddenFieldTag = require("../core/HiddenFieldTag");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");

const PostNudgeActions = React.createClass({
  propTypes: {
    updatePath: React.PropTypes.string.isRequired,
  },


  getInitialState() {
    // Possible currentActions:
    // - initial
    // - heardBack
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

    var action = "";

    switch (this.state.currentAction) {
      case "initial":
        helpText = "Let us know when you hear back from the bank:"
        break;
      case "heardBack":
        helpText = "What did the bank say?"
        break;
      case "confirmApproved":
        helpText = "Your application has been approved:"
        action = "open"
        break;
      case "confirmDenied":
        helpText = "Your application has been declined:"
        action = "deny"
        break;
    }

    switch (this.state.currentAction) {
      case "initial":
        buttons = (
          <Button
            primary
            small
            onClick={e => this.setCurrentAction(e, "heardBack") }
          >
            I heard back from the bank
          </Button>
        );
        break;
      case "heardBack":
        buttons = (
          <ApprovedDeniedPendingBtnGroup
            approvedText="My application was approved"
            deniedText="My application was declined"
            onClickApproved={e => this.setCurrentAction(e, "confirmApproved")}
            onClickDenied={e => this.setCurrentAction(e, "confirmDenied")}
          />
        );
        break;
      case "confirmApproved":
      case "confirmDenied":
        buttons = (
          <ConfirmOrCancelBtns
            small
            onClickCancel={e => this.setCurrentAction(e, "heardBack")}
          />
        );
        break;
    }

    return (
      <Form action={this.props.updatePath} method="patch">
        <HiddenFieldTag name="card_account[action]" value={action} />

        <p>{helpText}</p>

        {buttons}
      </Form>
    );
  },
});

module.exports = PostNudgeActions;
