const React = require("react");
const _     = require("underscore");

const Button      = require("../Button");
const ButtonGroup = require("../ButtonGroup");

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
    const props = _.clone(this.props);

    delete props.cancelBtnClass;
    delete props.cancelBtnId;
    delete props.confirmBtnClass;
    delete props.confirmBtnId;
    delete props.onClickConfirm;
    delete props.onClickCancel;
    delete props.small;

    return (
      <ButtonGroup {...props}>
        <Button
          className={this.props.confirmBtnClass}
          id={this.props.confirmBtnId}
          onClick={this.props.onClickConfirm}
          primary
          small={this.props.small}
        >
          Confirm
        </Button>
        <Button
          className={this.props.cancelBtnClass}
          default
          id={this.props.cancelBtnId}
          onClick={this.props.onClickCancel}
          small={this.props.small}
        >
          Cancel
        </Button>
      </ButtonGroup>
    );
  },
});

module.exports = ConfirmOrCancelBtns;
