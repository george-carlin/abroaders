const React = require("react");

const CardAccountAppliedActions = require("../CardAccountAppliedActions");
const CardAccountDeniedActions  = require("../CardAccountDeniedActions");
const CardAccountNudgeActions   = require("../CardAccountNudgeActions");
const CardAccountPostNudgeActions  = require("../CardAccountPostNudgeActions");
const CardAccountReconsiderActions = require("../CardAccountReconsiderActions");

const CardApplicationSurvey = React.createClass({

  propTypes: {
    card:        React.PropTypes.object.isRequired,
    bank:        React.PropTypes.object.isRequired,
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  render() {
    var   actions;
    const cardAccount = this.props.cardAccount;

    // Spaghetti code alert!!!!
    if (cardAccount.applied_at) {
      if (cardAccount.denied_at) {
        if (cardAccount.called_at) {
          if (!cardAccount.redenied_at) {
            actions = (
              <CardAccountReconsiderActions updatePath={this.props.updatePath} />
            );
          } // !redenied_at
        } else { // if !called_at:
          actions = (
            <CardAccountDeniedActions
              bank={this.props.bank}
              card={this.props.card}
              cardAccount={this.props.cardAccount}
              updatePath={this.props.updatePath}
            />
          );
        }
      } else {
        if (cardAccount.nudged_at)  {
          if (!(cardAccount.opened_at || cardAccount.denied_at)) {
            actions = (
              <CardAccountPostNudgeActions updatePath={this.props.updatePath} />
            );
          }
        } else {
          actions = (
            <CardAccountNudgeActions
              bank={this.props.bank}
              card={this.props.card}
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
