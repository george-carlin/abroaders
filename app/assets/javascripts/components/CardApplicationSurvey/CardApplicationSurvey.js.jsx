const React = require("react");

const CardAccountAppliedActions = require("../CardAccountAppliedActions");

const CardApplicationSurvey = React.createClass({


  propTypes: {
    cardAccount: React.PropTypes.object.isRequired,
    updatePath:  React.PropTypes.string.isRequired,
  },

  render() {
    var actions;

    if (this.props.cardAccount.appliedAt) {
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
