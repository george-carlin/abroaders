import React from "react";

import Button       from "../core/Button";
import ButtonGroup  from "../core/ButtonGroup";
import Form         from "../core/Form";
import TextField    from "../core/TextField";

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApplyOrDeclineBtns = React.createClass({
  propTypes: {
    applyPath:   React.PropTypes.string.isRequired,
    declinePath: React.PropTypes.string.isRequired,
  },


  getInitialState() {
    return { declineReason: "", isDeclining: false, showErrorMessage: false };
  },

  setIsDeclining(e, isDeclining) {
    e.preventDefault();
    this.setState({isDeclining: isDeclining});
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
        <Form action={this.props.declinePath} method="patch">
          {/* wrapper which will have field_with_errors class added */}
          <div className={declineReasonWrapperClass}>
            <TextField
              attribute="decline_reason"
              modelName="card_account"
              onChange={this.onChangeDeclineReason}
              placeholder="Why don't you want to apply for this card?"
              small
            />
          </div>
          <ConfirmOrCancelBtns
            small
            className="card_confirm_cancel_decline_btn_group"
            onClickCancel={e => this.setIsDeclining(e, false)}
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
        <ButtonGroup>
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
            onClick={e => this.setIsDeclining(e, true)}
          >
            No Thanks
          </Button>
        </ButtonGroup>
      )
    }

    return actions;
  },
});

module.exports = ApplyOrDeclineBtns;
