const React = require("react");

const Button              = require("../Button");
const Form                = require("../Form");
const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");
const TextFieldTag        = require("../TextFieldTag");

const CardAccountApplyOrDecline = React.createClass({
  propTypes: {
    applyPath:  React.PropTypes.string.isRequired,
    updatePath: React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return { declineReason: "", isDeclining: false, showErrorMessage: false };
  },

  onClickDecline() {
    this.setState({isDeclining: true});
  },

  onClickCancelDecline(e) {
    e.preventDefault();
    this.setState({isDeclining: false});
  },

  onClickConfirmDecline(e) {
    if (this.state.declineReason.trim()) {
      this.setState({showErrorMessage: false});
      // Let the form submit as normal
    } else {
      e.preventDefault();
      this.setState({showErrorMessage: true});
    }
  },

  onChangeDeclineReason(e) {
    this.setState({declineReason: e.target.value});
  },

  render() {
    var actions;

    var errorMessageStyle = {};
    var declineReasonWrapperClass = "card_account_decline_reason_wrapper";
    if (this.state.showErrorMessage) {
      declineReasonWrapperClass += " field_with_errors"
    } else {
      errorMessageStyle.display = "none";
    }

    if (this.state.isDeclining) {
      actions = (
        <Form action={this.props.updatePath} method="patch">
          <input type="hidden" name="card_account[status]" value="declined"/>

          {/* wrapper which will have field_with_errors class added */}
          <div className={declineReasonWrapperClass}>
            <TextFieldTag
              attribute="decline_reason"
              className="input-sm"
              modelName="card_account"
              onChange={this.onChangeDeclineReason}
              placeholder="Why don't you want to apply for this card?"
            />
          </div>
          <ConfirmOrCancelBtns
            small
            className="card_confirm_cancel_decline_btn_group"
            onClickCancel={this.onClickCancelDecline}
            onClickConfirm={this.onClickConfirmDecline}
          />

          <span
            className="decline_card_account_error_message"
            style={errorMessageStyle}
          >
            Please include a message
          </span>
        </Form>
      );
    } else {
      actions = (
        <div className="btn-group">
          <a
            href={this.props.applyPath}
            className="btn btn-primary btn-sm"
            target="_blank"
          >
            Apply
          </a>
          <Button
            small
            default
            onClick={this.onClickDecline}
          >
            No Thanks
          </Button>
        </div>
      )
    }

    return actions;
  },
});

module.exports = CardAccountApplyOrDecline;
