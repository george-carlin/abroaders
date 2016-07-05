const React = require("react");

const TextFieldTag = require("../core/TextFieldTag");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApproveCardAccountFormFields = React.createClass({
  propTypes: {
    askForDate:    React.PropTypes.bool,
    onClickCancel: React.PropTypes.func.isRequired,
    path:          React.PropTypes.string.isRequired,
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
      });
    }
  },


  formatDate(date) {
    function leadingZeroes(num) {
      num = num.toString();
      if (num.length < 2) num = "0" + num;
      return num;
    }

    const day   = leadingZeroes(date.getDate())
    const month = leadingZeroes(date.getMonth() + 1)
    const year  = date.getFullYear();

    return month + "/" + day + "/" + year;
  },


  render() {
    const confirmOrCancel = (
      <ConfirmOrCancelBtns
        className="card_account_confirm_approved_btn_group"
        onClickCancel={this.props.onClickCancel}
        small
      />
    );

    if (this.props.askForDate) {
      const openedAt = this.formatDate(new Date());

      // Note: removing ReactDOM from the global scope (30b7591b) broke this
      // component, as it was using ReactDOM from within componentDidMount.
      // However, adding `require("react-dom")` at the top the file still
      // didn't work because findDOMNode would raise an error about two copies
      // of React being present, although I can't find anything that might be
      // causing two copies of React to be loaded and don't understand why this
      // error was occurring. Having just spent a lot of time on it and got
      // nowhere, I'm resorting to a horribly hacky solution of adding
      // 'refFunction' as a property to TextFieldTag and getting the DOM node
      // that way. (Note that I can't just call 'ref' on TextFieldTag because
      // that gives me a ref to the component's backing instance rather than
      // the actual DOM node.)

      return (
        <div>
          <TextFieldTag
            attribute="opened_at"
            className="card_account_opened_at"
            defaultValue={openedAt}
            modelName="card_account"
            refFunction={(c) => this._textField = c}
            small
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
