const React = require("react");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const IHeardBackButton              = require("./IHeardBackButton");

const PostNudgeActions = React.createClass({
  propTypes: {
    submitAction: React.PropTypes.func.isRequired,
  },


  getInitialState() {
    // Possible currentStates:
    // - initial
    // - heardBack
    // - confirmApproved
    // - confirmDenied
    return { currentState: "initial" };
  },


  getAction() {
    switch (this.state.currentState) {
      case "confirmApproved":
        return "open";
      case "confirmDenied":
        return "deny";
      default:
        throw "this should never happen";
    }
  },


  getHelpText() {
    switch (this.state.currentState) {
      case "initial":
        return "Let us know when you hear back from the bank:";
      case "heardBack":
        return "What did the bank say?";
      case "confirmApproved":
        return "Your application has been approved:";
      case "confirmDenied":
        return "Your application has been declined:";
    }
  },


  setStateToApproved() {
    this.setState({currentState: "confirmApproved"});
  },


  setStateToDenied() {
    this.setState({currentState: "confirmDenied"});
  },


  setStateToInitial() {
    this.setState({currentState: "initial"});
  },


  setStateToHeardBack() {
    this.setState({currentState: "heardBack"});
  },


  submitAction() {
    this.props.submitAction(this.getAction());
  },


  render() {
    return (
      <div>
        <p>{this.getHelpText()}</p>

        {(() => {
          switch (this.state.currentState) {
            case "initial":
              return (
                <IHeardBackButton
                  onClick={this.setStateToHeardBack}
                />
              );
            case "heardBack":
              return (
                <ApprovedDeniedPendingBtnGroup
                  approvedText="My application was approved"
                  deniedText="My application was declined"
                  onClickApproved={this.setStateToApproved}
                  onClickDenied={this.setStateToDenied}
                />
              );
            case "confirmApproved":
            case "confirmDenied":
              return (
                <ConfirmOrCancelBtns
                  onClickCancel={this.setStateToHeardBack}
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

module.exports = PostNudgeActions;
