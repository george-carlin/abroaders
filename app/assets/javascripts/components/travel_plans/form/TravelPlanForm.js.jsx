var TravelPlanForm = React.createClass({
  propTypes: {
    defaultType: React.PropTypes.string.isRequired,
    maxLegs:     React.PropTypes.number.isRequired,
    planTypes:   React.PropTypes.array.isRequired,
    travelPlan:  React.PropTypes.object.isRequired,
  },


  getInitialState() {
    return {
      type: this.props.defaultType,
      legs: [{}],
    }
  },


  noOfLegs() {
    return this.state.legs.length;
  },


  addLeg() {
    var legs = this.state.legs;
    legs.push({})
    this.setState({legs: legs});
  },


  changeType(e) {
    this.setState({ type: e.target.value });
  },


  removeLeg(e) {
    var legs = this.state.legs;
    // remove this leg from the array:
    legs.splice(e.target.dataset.legIndex, 1)
    this.setState({ legs: legs });
  },


  render() {
    var that = this;

    var legs = [];
    for (var i = 0; i < this.noOfLegs(); i++) {
      legs.push(
        <TravelPlanLegFields
          key={i}
          index={i}
          showRemoveBtn={this.state.type === "multi" && this.noOfLegs() > 1}
          onRemoveBtnClick={this.removeLeg}
        />
      );
    };

    return (
      <div>
        <div className="row">
          <TravelPlanTypeRadios
            types={this.props.planTypes}
            currentType={this.state.type}
            onChange={this.changeType}
          />
        </div>

        {legs}

        <div className="row">
          <div className="col-xs-4">
            <label>No of passengers</label>
            <NumberFieldTag
              model="travel_plan"
              field="no_of_passengers"
              value={this.props.travelPlan.no_of_passengers}
            />
          </div>

          <div className="col-xs-2">
            <TravelPlanAddLegBtn
              hidden={this.state.type !== "multi"}
              onClick={this.addLeg}
            />
          </div>
        </div>
      </div>
    )
  }
});
