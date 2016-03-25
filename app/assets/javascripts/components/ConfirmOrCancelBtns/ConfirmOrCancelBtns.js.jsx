const React = require("react");

const Button = require("../Button");

const ConfirmOrCancelBtns = React.createClass({

  propTypes: {
    cancelBtnClass:  React.PropTypes.string,
    cancelBtnId:     React.PropTypes.string,
    confirmBtnClass: React.PropTypes.string,
    confirmBtnId:    React.PropTypes.string,
    onClickConfirm:  React.PropTypes.func,
    onClickCancel:   React.PropTypes.func,
    small:           React.PropTypes.bool,
  },


  render() {
    return (
      <div>
        <Button
          className={this.props.cancelBtnClass}
          default
          id={this.props.cancelBtnId}
          onClick={this.props.onClickCancel}
          small={this.props.small}
        >
          Cancel
        </Button>
        <Button
          className={this.props.confirmBtnClass}
          id={this.props.confirmBtnId}
          onClick={this.props.onClickConfirm}
          primary
          small={this.props.small}
        >
          Confirm
        </Button>
      </div>
    );
  },
});

module.exports = ConfirmOrCancelBtns;
