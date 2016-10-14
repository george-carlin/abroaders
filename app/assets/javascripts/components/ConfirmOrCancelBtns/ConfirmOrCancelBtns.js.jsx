import React from "react";
import _     from "underscore";

import Button      from "../core/Button";
import ButtonGroup from "../core/ButtonGroup";

const ConfirmOrCancelBtns = (_props) => {
  const props = Object.assign({}, _props);

  const propsClone = _.clone(props);

  delete propsClone.cancelBtnClass;
  delete propsClone.cancelBtnId;
  delete propsClone.confirmBtnClass;
  delete propsClone.confirmBtnId;
  delete propsClone.onClickConfirm;
  delete propsClone.onClickCancel;
  delete propsClone.small;

  return (
    <ButtonGroup {...propsClone}>
      <Button
        className={props.confirmBtnClass}
        id={props.confirmBtnId}
        onClick={props.onClickConfirm}
        primary
        small={props.small}
      >
        Confirm
      </Button>
      <Button
        className={props.cancelBtnClass}
        default
        id={props.cancelBtnId}
        onClick={props.onClickCancel}
        small={props.small}
      >
        Cancel
      </Button>
    </ButtonGroup>
  );
};

ConfirmOrCancelBtns.propTypes = Object.assign(
  {
    cancelBtnClass:  React.PropTypes.string,
    cancelBtnId:     React.PropTypes.string,
    confirmBtnClass: React.PropTypes.string,
    confirmBtnId:    React.PropTypes.string,
    onClickConfirm:  React.PropTypes.func,
    onClickCancel:   React.PropTypes.func,
    small:           React.PropTypes.bool,
  }
);

export default ConfirmOrCancelBtns;
