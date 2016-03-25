const React = require('react');

const AuthTokenField = require("../AuthTokenField");
const Button         = require("../Button");

const CardDeclineForm = React.createClass({
  getInitialState() {
    return {
      csrfToken:        "",
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

  // TODO this is an exact dupe of code in TravelPlanForm. How to DRY this?
  componentDidMount() {
    // Hack to get the csrf-token into the form. `csrf_meta_tags` doesn't
    // output anything in test mode, so only add this hack if the querySelector
    // returns anything:
    var csrfMetaTag = document.querySelector('meta[name="csrf-token"]')
    if (csrfMetaTag) {
      this.setState({
        csrfToken: csrfMetaTag.content
      });
    }
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
        <AuthTokenField value={this.state.csrfToken} />

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
        <Button
          className="card_account_cancel_decline_btn"
          default
          id={`card_account_${this.props.accountId}_cancel_decline_btn`}
          onClick={this.props.onClickCancel}
          small
        >
          Cancel
        </Button>
        <Button
          className="card_account_confirm_decline_btn"
          id={`card_account_${this.props.accountId}_confirm_decline_btn`}
          primary
          small
        >
          Confirm
        </Button>

        {this.state.showErrorMessage ?
          <span className="decline_card_recommendation_error_message">
            Please include a message
          </span> : false }
      </form>
    )
  }

});

module.exports = CardDeclineForm;
