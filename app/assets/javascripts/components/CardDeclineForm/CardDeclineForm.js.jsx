const React = require('react');

const AuthTokenField = require("../AuthTokenField");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns")

const CardDeclineForm = React.createClass({
  getInitialState() {
    return {
      declineMessage:   "",
      isDeclining:      false,
      showErrorMessage: false
    }
  },

  propTypes: {
    accountId:     React.PropTypes.number.isRequired,
    declinePath:   React.PropTypes.string.isRequired,
    onClickCancel: React.PropTypes.func.isRequired,
  },


  submit(e) {
    if (this.state.declineMessage.trim()) {
      this.setState({ showErrorMessage: false});
    } else {
      this.setState({ showErrorMessage: true});
      e.preventDefault();
    }
  },

  handleDeclineMessageChange(e) {
    this.setState({declineMessage: e.target.value});
  },

  render() {
    var that = this;
    return (
      <form
        action={this.props.declinePath}
        method="post"
        onSubmit={this.submit}
      >
        <AuthTokenField />

        <div className={this.state.showErrorMessage ? "field_with_errors" : ""}>
          <input
            className="form-control input-sm"
            id="card_account_decline_reason"
            name="card_account[decline_reason]"
            type="text"
            onChange={this.handleDeclineMessageChange}
            value={this.state.declineMessage}
          />
        </div>

        <ConfirmOrCancelBtns
          confirmBtnClass="card_account_cancel_decline_btn"
          confirmBtnId={`card_account_${this.props.accountId}_confirm_decline_btn`}
          cancelBtnClass="card_account_confirm_decline_btn"
          cancelBtnId={`card_account_${this.props.accountId}_cancel_decline_btn`}
          onClickCancel={this.props.onClickCancel}
          small
        />

        {this.state.showErrorMessage ?
          <span className="decline_card_recommendation_error_message">
            Please include a message
          </span> : false }
      </form>
    )
  }

});

module.exports = CardDeclineForm;
