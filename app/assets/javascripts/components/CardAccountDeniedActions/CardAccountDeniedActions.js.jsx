const React = require("react");

const ApprovedPendingOrDeniedBtns = require("../ApprovedPendingOrDeniedBtns");
const Button                      = require("../Button");
const ConfirmOrCancelBtns         = require("../ConfirmOrCancelBtns");
const Form                        = require("../Form");

const CardAccountDeniedActions = React.createClass({
  propTypes: {
    updatePath: React.PropTypes.string.isRequired,
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
    let buttons, helpText, action;

    switch (this.state.currentAction) {
      case "initial":
        helpText = "Please let us know when you've called the bank:"
        break;
      case "called":
        helpText = "How did it go?"
        break;
      case "confirmApproved":
        action = "open_after_call";
        helpText = "You were approved after calling for reconsideration:"
        break;
      case "confirmDenied":
        helpText = "You called for reconsideration, but your application is still denied:"
        action = "redeny";
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
            I called
          </Button>
        );
        break;
      case "called":
        buttons = (
          <div className="btn-group">
            <Button
              small
              primary
              onClick={e => this.setCurrentAction(e, "confirmApproved")}
            >
              I was approved after reconsideration
            </Button>
            <Button
              small
              default
              onClick={e => this.setCurrentAction(e, "confirmDenied")}
            >
              My application is still denied
            </Button>
            <Button
              small
              default
              onClick={e => this.setCurrentAction(e, "confirmPending")}
            >
              I'm being reconsidered, but waiting to hear back about whether it was successful
            </Button>
          </div>
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

    return (
      <div>
        <Form action={this.props.updatePath} method="patch">
          <input type="hidden" name="card_account[action]" value={action} />

          <p>
            We strongly recommend that you call BANK at BANK PERSONAL/BIZ PHONE
            as soon as possible to ask for a real person to review your
            application by phone.
          </p>

          <p>
            More than 30% of applications that are initially denied are
            overturned with a 5-10 minute phone call.
          </p>

          <p>{helpText}</p>

          {buttons}
        </Form>
      </div>
    );
  },
});

module.exports = CardAccountDeniedActions;
