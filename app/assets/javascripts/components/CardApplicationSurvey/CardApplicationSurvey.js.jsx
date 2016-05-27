const React = require("react");

const CardAccountAppliedActions = require("../CardAccountAppliedActions");
const CardAccountDeniedActions  = require("../CardAccountDeniedActions");
const CardAccountNudgeActions   = require("../CardAccountNudgeActions");
const CardAccountPostNudgeActions  = require("../CardAccountPostNudgeActions");
const CardAccountReconsiderActions = require("../CardAccountReconsiderActions");

const CardApplicationSurvey = React.createClass({

  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  render() {
    var   actions;
    const cardAccount = this.props.cardAccount;

    // Spaghetti code alert!!!!
    if (cardAccount.appliedAt) {
      if (cardAccount.deniedAt) {
        if (cardAccount.calledAt) {
          if (!cardAccount.redeniedAt) {
            actions = (
              <CardAccountReconsiderActions updatePath={this.props.updatePath} />
            );
          } // !redenied_at
        } else { // if !called_at:
          actions = (
            <CardAccountDeniedActions
              cardAccount={this.props.cardAccount}
              updatePath={this.props.updatePath}
            />
          );
        }
      } else {
        if (cardAccount.nudgedAt)  {
          if (!(cardAccount.openedAt || cardAccount.deniedAt)) {
            actions = (
              <CardAccountPostNudgeActions updatePath={this.props.updatePath} />
            );
          }
        } else {
          actions = (
            <CardAccountNudgeActions
              cardAccount={this.props.cardAccount}
              updatePath={this.props.updatePath}
            />
          )
        }
      }
    } else { // appliedAt not present
      actions = (
        <CardAccountAppliedActions 
          cardAccount={this.props.cardAccount}
          updatePath={this.props.updatePath}
        />
      )
    }
    
    return (
      <div>
        {actions}
      </div>
    );
  },
});

module.exports = CardApplicationSurvey;
