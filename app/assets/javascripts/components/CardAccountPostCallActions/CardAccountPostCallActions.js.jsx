const React = require("react");

const ApprovedDeniedPendingBtnGroup = require("../ApprovedDeniedPendingBtnGroup");
const Button              = require("../Button");
const ButtonGroup         = require("../ButtonGroup");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");
const Form                = require("../Form");
const HiddenFieldTag      = require("../HiddenFieldTag");

const CardAccountPostCallActions = React.createClass({
  propTypes: {
    updatePath:  React.PropTypes.string.isRequired,
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
        helpText = "Tell us when you hear back from the bank:"
        break;
      case "heardBack":
        helpText = "What did the bank say?"
        break;
      case "confirmApproved":
        helpText = "Your application has been approved after reconsideration:"
        action = "open"
        break;
      case "confirmDenied":
        helpText = "Your application is still denied after reconsideration:"
        action = "redeny"
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
            approvedText="My application was approved after reconsideration"
            deniedText="My application is still denied"
            onClickApproved={e => this.setCurrentAction(e, "confirmApproved")}
            onClickDenied={e => this.setCurrentAction(e, "confirmDenied")}
            noPendingBtn
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

        <p>
          You have indicated that your application was denied, you called
          for reconsideration, and you're waiting to hear the results.
        </p>

        <p>{helpText}</p>

        {buttons}
      </Form>
    );
  },
});

module.exports = CardAccountPostCallActions;
