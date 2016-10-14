import React from "react";

import Button      from "../core/Button";
import ButtonGroup from "../core/ButtonGroup";

const ApprovedDeniedPendingBtnGroup = (_props) => {
  const props = Object.assign({}, _props);
  let pendingBtn, cancelBtn;

  if (props.pendingText && props.onClickPending) {
    pendingBtn = (
      <Button
        default
        onClick={props.onClickPending}
        small
      >
      {props.pendingText}
      </Button>
    );
  }

  if (props.onCancel) {
    cancelBtn = (
      <Button
        default
        onClick={props.onCancel}
        small
      >
        Cancel
      </Button>
    );
  }

  return (
    <ButtonGroup>
      <Button
        onClick={props.onClickApproved}
        primary
        small
      >
      {props.approvedText}
      </Button>

      <Button
        default
        onClick={props.onClickDenied}
        small
      >
      {props.deniedText}
      </Button>

      {pendingBtn}
      {cancelBtn}
    </ButtonGroup>
  );
};

ApprovedDeniedPendingBtnGroup.propTypes = Object.assign(
  {
    approvedText:    React.PropTypes.string.isRequired,
    deniedText:      React.PropTypes.string.isRequired,
    onClickApproved: React.PropTypes.func.isRequired,
    onClickDenied:   React.PropTypes.func.isRequired,
    // The 'pending' button will only be shown if both the onClickPending and
    // pendingText props are present
    onClickPending:  React.PropTypes.func,
    pendingText:     React.PropTypes.string,
    // Leave onCancel blank and no 'Cancel' button will be rendered:
    onCancel:        React.PropTypes.func,
  }
);

export default ApprovedDeniedPendingBtnGroup;
