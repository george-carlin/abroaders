var CardApplyBtn = React.createClass({
  propTypes: {
    accountId: React.PropTypes.number.isRequired,
    path:      React.PropTypes.string.isRequired,
  },

  render() {
    return (
      <a
        id={`card_account_${this.context.accountId}_apply_btn`}
        href={this.props.path}
        className="card_account_apply_btn btn btn-primary btn-sm"
        target="_blank"
      >
        Apply
      </a>
    )
  }
});
