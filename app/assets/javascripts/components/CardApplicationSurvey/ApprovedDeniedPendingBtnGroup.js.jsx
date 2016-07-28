const React = require("react");

const Button      = require("../core/Button");
const ButtonGroup = require("../core/ButtonGroup");

const ApprovedDeniedPendingBtnGroup = React.createClass({
  propTypes: {
    approvedText:    React.PropTypes.string.isRequired,
    deniedText:      React.PropTypes.string.isRequired,
    noPendingBtn:    React.PropTypes.bool,
    onClickApproved: React.PropTypes.func.isRequired,
    onClickDenied:   React.PropTypes.func.isRequired,
    onClickPending:  React.PropTypes.func,
    pendingText:     React.PropTypes.string,
    // Leave onCancel blank and no 'Cancel' button will be rendered:
    onCancel:        React.PropTypes.func,
  },


  render() {
    let pendingBtn, cancelBtn;

    if (!this.props.noPendingBtn) {
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
