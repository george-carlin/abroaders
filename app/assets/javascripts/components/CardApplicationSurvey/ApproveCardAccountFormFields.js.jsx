/* global $ */
// Technical debt alert: we can't `import $` because then it won't have the
// .typehead func defined on it. Instead we have to use the window.$ object
// that's added by the asset pipeiple. I tried to fix this by adding
// bootstrap-datepicker as an NPM package (instead of including it in
// vendor/assets) but can't figure out how to make it work with ES6 'import'
// statements. (I suspect it's not possible at all in our current setup.) See
// https://github.com/Eonasdan/bootstrap-datetimepicker/issues/576
import React from "react";

import TextField from "../core/TextField";

import ConfirmOrCancelBtns from "../ConfirmOrCancelBtns";

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
        className="card_confirm_approved_btn_group"
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
            className="card_opened_on form-control input-sm"
            defaultValue={this.props.openedAt}
            id="card_opened_on"
            modelName="card"
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

export default ApproveCardAccountFormFields;
