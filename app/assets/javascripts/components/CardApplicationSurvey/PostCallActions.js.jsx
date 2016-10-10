import React from "react";

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApprovedDeniedPendingBtnGroup = require("./ApprovedDeniedPendingBtnGroup");
const IHeardBackButton              = require("./IHeardBackButton");

const PostCallActions = React.createClass({
  propTypes: {
    submitAction: React.PropTypes.func.isRequired,
  },


  getInitialState() {
    // Possible currentState:
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
        return "redeny";
      default:
        throw "this should never happen";
    }
  },


  getHelpText() {
    switch (this.state.currentState) {
      case "initial":
        return "Tell us when you hear back from the bank:";
      case "heardBack":
        return "What did the bank say?";
      case "confirmApproved":
        return "Your application has been approved after reconsideration:";
      case "confirmDenied":
        return "Your application is still denied after reconsideration:";
    }
  },


  setStateToApproved() {
    this.setState({currentState: "confirmApproved"});
  },


  setStateToDenied() {
    this.setState({currentState: "confirmDenied"});
  },


  setStateToHeardBack() {
    this.setState({currentState: "heardBack"});
  },


  setStateToInitial() {
    this.setState({currentState: "initial"});
  },


  submitAction() {
    this.props.submitAction(this.getAction());
  },


  render() {
    return (
      <div>
        <p>
          You have indicated that your application was denied, you called
          for reconsideration, and you're waiting to hear the results.
        </p>

        <p>{this.getHelpText()}</p>

        {(() => {
          switch (this.state.currentState) {
            case "initial":
              return <IHeardBackButton onClick={this.setStateToHeardBack} />;
            case "heardBack":
              return (
                <ApprovedDeniedPendingBtnGroup
                  approvedText="My application was approved after reconsideration"
                  deniedText="My application is still denied"
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

module.exports = PostCallActions;
