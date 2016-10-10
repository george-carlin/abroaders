import React from "react";

import Button      from "../core/Button";
import ButtonGroup from "../core/ButtonGroup";

const ApprovedDeniedPendingBtnGroup = React.createClass({
  propTypes: {
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
  },


  render() {
    let pendingBtn, cancelBtn;

    if (this.props.pendingText && this.props.onClickPending) {
      pendingBtn = (
        <Button
          default
          onClick={this.props.onClickPending}
          small
        >
          {this.props.pendingText}
        </Button>
      );
    }

    if (this.props.onCancel) {
      cancelBtn = (
        <Button
          default
          onClick={this.props.onCancel}
          small
          >
          Cancel
        </Button>
      );
    }

    return (
      <ButtonGroup>
        <Button
          onClick={this.props.onClickApproved}
          primary
          small
        >
          {this.props.approvedText}
        </Button>
        <Button
          default
          onClick={this.props.onClickDenied}
          small
        >
          {this.props.deniedText}
        </Button>
        {pendingBtn}
        {cancelBtn}
      </ButtonGroup>
    )
  },
});

module.exports = ApprovedDeniedPendingBtnGroup;
