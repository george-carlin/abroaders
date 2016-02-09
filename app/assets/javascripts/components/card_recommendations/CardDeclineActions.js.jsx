var CardDeclineActions = React.createClass({
  propTypes: {
    accountId:       React.PropTypes.number.isRequired,
    declinePath:     React.PropTypes.string.isRequired,
    isDeclining:     React.PropTypes.bool.isRequired,
    onClickDecline:  React.PropTypes.func.isRequired,
    onCancelDecline: React.PropTypes.func.isRequired,
  },

  render() {
    var that = this;
    return (
      <div>
        {(function () {
          if (that.props.isDeclining) {
            return (
              <CardDeclineForm
                accountId={that.props.accountId}
                declinePath={that.props.declinePath}
                onClickCancel={that.props.onCancelDecline}
              />
            );
          } else {
            return (
              <button
                id={`card_account_${that.props.accountId}_decline_btn`}
                className="card_account_decline_btn btn btn-default btn-sm"
                onClick={that.props.onClickDecline}
              >
                No Thanks
              </button>
            )
          }
        })()}
      </div>
    )
  }

});
