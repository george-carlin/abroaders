const React = require("react");

const CardApplyBtn       = require("../CardApplyBtn");
const CardDeclineActions = require("../CardDeclineActions");

const CardAccountStatuses = ["unknown", "recommended", "declined", "applied", "denied", "open", "closed"];

const CardRecommendationActions = React.createClass({
  getInitialState() {
    return { isDeclining: false }
  },

  propTypes: {
    accountId:   React.PropTypes.number.isRequired,
    applyPath:   React.PropTypes.string.isRequired,
    declinePath: React.PropTypes.string.isRequired,
    // CardAccountStatuses is defined in load.js.erb:
    status: React.PropTypes.oneOf(CardAccountStatuses).isRequired,
  },

  clickedDecline() {
    this.setState({ isDeclining: true });
  },

  canceledDecline(e) {
    e.preventDefault();
    this.setState({ isDeclining: false });
  },

  render() {
    return (
      <div className="CardRecommendationActions">
        {this.state.isDeclining ? false :
          <CardApplyBtn
            accountId={this.props.accountId}
            path={this.props.applyPath}
          />
        }

        <CardDeclineActions
          accountId={this.props.accountId}
          declinePath={this.props.declinePath}
          isDeclining={this.state.isDeclining}
          onClickDecline={this.clickedDecline}
          onCancelDecline={this.canceledDecline}
        />
      </div>
    )
  }

})

module.exports = CardRecommendationActions;
