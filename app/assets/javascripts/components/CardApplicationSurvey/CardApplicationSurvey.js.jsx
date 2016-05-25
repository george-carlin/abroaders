const React = require("react");

const CardAccountAppliedActions = require("../CardAccountAppliedActions");
const CardAccountDeniedActions  = require("../CardAccountDeniedActions");

const CardApplicationSurvey = React.createClass({

  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  render() {
    var   actions;
    const cardAccount = this.props.cardAccount;

    if (cardAccount.applied_at) {
      if (cardAccount.denied_at) {
        actions = (
          <CardAccountDeniedActions
            updatePath={this.props.updatePath}
          />
        )
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
