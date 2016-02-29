var React = require('react');

var CardDeclineActions = React.createClass({

  propTypes: {
    accountId:       React.PropTypes.number.isRequired,
    declinePath:     React.PropTypes.string.isRequired,
    isDeclining:     React.PropTypes.bool.isRequired,
    onClickDecline:  React.PropTypes.func.isRequired,
    onCancelDecline: React.PropTypes.func.isRequired,
  },


  render() {
    var formOrButton;

    if (this.props.isDeclining) {
      formOrButton = (
        <CardDeclineForm
          accountId={this.props.accountId}
          declinePath={this.props.declinePath}
          onClickCancel={this.props.onCancelDecline}
        />
      );
    } else {
      formOrButton = (
        <button
          id={`card_account_${this.props.accountId}_decline_btn`}
          className="card_account_decline_btn btn btn-default btn-sm"
          onClick={this.props.onClickDecline}
        >
          No Thanks
        </button>
      );
    }

    return (
      <div>{formOrButton}</div>
    );
  },

});

module.exports = CardDeclineActions;
