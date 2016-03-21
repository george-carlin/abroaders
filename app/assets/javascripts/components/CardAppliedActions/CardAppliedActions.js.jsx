const React = require("react");

const Button = require("../Button");

// const CardAccountStatuses = ["unknown", "recommended", "declined", "applied", "denied", "open", "closed"];

const CardAppliedActions = React.createClass({
  getInitialState() {
    return { isConfirmingApproval: false }
  },

  // propTypes: {
  //   accountId:   React.PropTypes.number.isRequired,
  //   applyPath:   React.PropTypes.string.isRequired,
  //   declinePath: React.PropTypes.string.isRequired,
  //   // CardAccountStatuses is defined in load.js.erb:
  //   status: React.PropTypes.oneOf(CardAccountStatuses).isRequired,
  // },

  clickedApproved() {
    this.setState({ isConfirmingApproval: true });
  },

  canceledApproved(e) {
    e.preventDefault();
    this.setState({ isConfirmingApproval: false });
  },

  render() {
    return (
      <div className="CardAppliedActions">
        {(() => {
          if (this.state.isConfirmingApproval) {
            return (
              <div>
                <Button
                  onClick={this.confirmedApproved}
                  primary
                  small
                >
                  Confirm
                </Button>

                <Button
                  onClick={this.canceledApproved}
                  default
                  small
                >
                  Cancel
                </Button>
              </div>
            );
          } else {
            return (
              <div>
                <Button
                  onClick={this.clickedApproved}
                  primary
                  small
                >
                  I have been approved
                </Button>

                <Button
                  default
                  small
                >
                  I have been declined
                </Button>
              </div>
            );
          }
        })()}
      </div>
    )
  }

})

module.exports = CardAppliedActions;
