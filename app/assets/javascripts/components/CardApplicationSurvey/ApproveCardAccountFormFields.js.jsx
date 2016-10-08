import React from "react";

const TextField = require("../core/TextField");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApproveCardAccountFormFields = React.createClass({
  propTypes: {
    askForDate:    React.PropTypes.bool,
    onClickCancel: React.PropTypes.func.isRequired,
    openedAt:      React.PropTypes.string.isRequired,
    setOpenedAt:   React.PropTypes.func.isRequired,
    submitAction:  React.PropTypes.func.isRequired,
  },


  getInitialState() {
    const today = new Date(),
          m = today.getMonth(),
          d = today.getDate(),
          y = today.getFullYear();
    return { openedAt: m + "/" + d + "/" + y };
  },


  componentDidMount() {
    if (this.props.askForDate) {
      const today = new Date(),
            thisYear  = today.getFullYear(),
            thisMonth = today.getMonth(),
            thisDate  = today.getDate(),
            twoMonthsAgo = new Date(thisYear, thisMonth - 2, thisDate);

      const $input = $(this._textField);

      $input.datepicker({
        defaultViewDate: { year: thisYear, month: thisMonth, date: thisDate },
        endDate: today,
        startDate: twoMonthsAgo,
        startView: 1,
        maxViewMode: 0,
        autoclose: true,
        todayHighlight: true,
      }).on("changeDate", (e) => {
        // See https://bootstrap-datepicker.readthedocs.io/en/latest/events.html#changedate
        const date = e.format("mm/dd/yyyy");
        this.props.setOpenedAt(date);
      });
    }
  },


  submitAction() {
    if (this.props.askForDate) {
      this.props.submitAction("open", this.state.openedAt);
    } else {
      this.props.submitAction("open");
    }
  },


  render() {
    const confirmOrCancel = (
      <ConfirmOrCancelBtns
        className="card_account_confirm_approved_btn_group"
        onClickCancel={this.props.onClickCancel}
        onClickConfirm={this.props.submitAction}
        small
      />
    );

    if (this.props.askForDate) {
      const setTextField = (ref) => {
        this._textField = ref;
      };

      return (
        <div>
          <input
            className="card_account_opened_at form-control input-sm"
            defaultValue={this.props.openedAt}
            id="card_account_opened_at"
            modelName="card_account"
            ref={setTextField}
            small
            type="text"
          />
          {confirmOrCancel}
        </div>
      );
    } else {
      return confirmOrCancel;
    }
  },

});

module.exports = ApproveCardAccountFormFields;
