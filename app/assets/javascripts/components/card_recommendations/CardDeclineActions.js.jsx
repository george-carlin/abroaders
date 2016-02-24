function CardDeclineActions(props) {
  var formOrButton;

  if (props.isDeclining) {
    formOrButton = (
      <CardDeclineForm
        accountId={props.accountId}
        declinePath={props.declinePath}
        onClickCancel={props.onCancelDecline}
      />
    );
  } else {
    formOrButton = (
      <button
        id={`card_account_${props.accountId}_decline_btn`}
        className="card_account_decline_btn btn btn-default btn-sm"
        onClick={props.onClickDecline}
      >
        No Thanks
      </button>
    );
  }

  return (
    <div>{formOrButton}</div>
  );
};

CardDeclineActions.propTypes = {
  accountId:       React.PropTypes.number.isRequired,
  declinePath:     React.PropTypes.string.isRequired,
  isDeclining:     React.PropTypes.bool.isRequired,
  onClickDecline:  React.PropTypes.func.isRequired,
  onCancelDecline: React.PropTypes.func.isRequired,
};
