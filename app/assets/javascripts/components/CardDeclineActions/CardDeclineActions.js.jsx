const React = require('react');

const Button          = require("../Button");
const CardDeclineForm = require("../CardDeclineForm");

const CardDeclineActions = React.createClass({

  propTypes: {
    accountId:       React.PropTypes.number.isRequired,
    declinePath:     React.PropTypes.string.isRequired,
    isDeclining:     React.PropTypes.bool.isRequired,
    onClickDecline:  React.PropTypes.func.isRequired,
    onCancelDecline: React.PropTypes.func.isRequired,
  },


  render() {
    if (this.props.isDeclining) {
      return (
        <CardDeclineForm
          accountId={this.props.accountId}
          declinePath={this.props.declinePath}
          onClickCancel={this.props.onCancelDecline}
        />
      );
    } else {
      return (
        <Button
          className="card_account_decline_btn"
          default
          id={`card_account_${this.props.accountId}_decline_btn`}
          onClick={this.props.onClickDecline}
          small
        >
          No Thanks
        </Button>
      );
    }
  },

});

module.exports = CardDeclineActions;
