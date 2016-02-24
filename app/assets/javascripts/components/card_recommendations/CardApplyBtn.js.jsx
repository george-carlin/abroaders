function CardApplyBtn(props) {
  return (
    <a
      id={`card_account_${props.accountId}_apply_btn`}
      href={props.path}
      className="card_account_apply_btn btn btn-primary btn-sm"
      target="_blank"
    >
      Apply
    </a>
  );
};

CardApplyBtn.propTypes = {
  accountId: React.PropTypes.number.isRequired,
  path:      React.PropTypes.string.isRequired,
};
