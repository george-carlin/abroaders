var TravelPlanFormAddLegBtn = React.createClass({
  didClick(e) {
    e.preventDefault();
    this.props.onClickCallback()
  },

  render() {
    if (this.props.hidden) {
      return <div></div>
    } else {
      return (
        <button onClick={this.didClick}
                className="add-travel-plan-leg-btn btn btn-primary">+</button>
      )
    }
  }
});
