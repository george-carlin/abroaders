var TravelPlanTypeSelect = React.createClass({

  propTypes: {
    changeTypeCallback: React.PropTypes.func.isRequired
  },

  render() {
    return (
      <div className="row">
        <div className="col-xs-12">
          <label>
            Single
            &nbsp;
            <input type="radio" name="travel_plan_type" value="single"
                       onClick={this.props.changeTypeCallback} />
          </label>
          &nbsp;
          <label>
            Return
            &nbsp;
            <input type="radio" name="travel_plan_type" value="return"
                       defaultChecked
                       onClick={this.props.changeTypeCallback} />
          </label>
          &nbsp;
          <label>
            Multi-city
            &nbsp;
            <input type="radio" name="travel_plan_type" value="multicity"
                       onClick={this.props.changeTypeCallback} />
          </label>
        </div>
      </div>
    )
  }
});
