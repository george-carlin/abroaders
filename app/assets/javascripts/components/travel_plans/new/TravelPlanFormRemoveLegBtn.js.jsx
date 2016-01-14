var TravelPlanFormRemoveLegBtn = React.createClass({
  render() {
    if (this.props.hidden) {
      return <div></div>
    } else {
      return (
        <button onClick={this.props.onClickCallback}
                className="remove-travel-plan-leg-btn btn btn-default">-</button>
      )
    }
  }
});
