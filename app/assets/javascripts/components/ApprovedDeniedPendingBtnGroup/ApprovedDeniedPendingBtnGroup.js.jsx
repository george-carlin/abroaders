const React = require("react");

const Button      = require("../Button");
const ButtonGroup = require("../ButtonGroup");

const ApprovedDeniedPendingBtnGroup = React.createClass({
  propTypes: {
    approvedText:    React.PropTypes.string.isRequired,
    deniedText:      React.PropTypes.string.isRequired,
    noPendingBtn:    React.PropTypes.bool,
    onClickApproved: React.PropTypes.func.isRequired,
    onClickDenied:   React.PropTypes.func.isRequired,
    onClickPending:  React.PropTypes.func,
    pendingText:     React.PropTypes.string,
  },


  render() {
    var pendingBtn;

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
      </ButtonGroup>
    )
  },
});

module.exports = ApprovedDeniedPendingBtnGroup;
