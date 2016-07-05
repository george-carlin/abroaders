const React    = require("react");
const ReactDOM = require("react-dom");

const TextFieldTag = require("../core/TextFieldTag");

const ConfirmOrCancelBtns = require("../ConfirmOrCancelBtns");

const ApproveCardAccountFormFields = React.createClass({
  propTypes: {
    askForDate:    React.PropTypes.bool,
    onClickCancel: React.PropTypes.func.isRequired,
    path:          React.PropTypes.string.isRequired,
  },


  componentDidMount() {
    const that = this;

    if (this.props.askForDate) {
      const today = new Date(),
      thisYear  = today.getFullYear(),
      thisMonth = today.getMonth(),
      thisDate  = today.getDate(),
      twoMonthsAgo = new Date(thisYear, thisMonth - 2, thisDate);

      const $input = $(ReactDOM.findDOMNode(this)).find("input[type=text]");

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

      return (
        <div>
          <TextFieldTag
            attribute="opened_at"
            className="card_account_opened_at"
            defaultValue={openedAt}
            modelName="card_account"
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
