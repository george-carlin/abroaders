import React from "react";
import _     from "underscore";

import Button      from "../core/Button";
import ButtonGroup from "../core/ButtonGroup";

const ConfirmOrCancelBtns = (_props) => {
  const props = Object.assign({}, _props);

  const propsClone = _.clone(props);

  delete propsClone.onClickConfirm;
  delete propsClone.onClickCancel;
  delete propsClone.small;

  return (
    <ButtonGroup {...propsClone}>
      <Button
        onClick={props.onClickConfirm}
        primary
        small={props.small}
      >
        Confirm
      </Button>
      <Button
        default
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
    onClickConfirm:  React.PropTypes.func,
    onClickCancel:   React.PropTypes.func,
    small:           React.PropTypes.bool,
  }
);

export default ConfirmOrCancelBtns;
