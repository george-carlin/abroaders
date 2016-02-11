var TravelPlanForm = React.createClass({
  propTypes: {
    defaultType: React.PropTypes.string.isRequired,
    maxFlights:  React.PropTypes.number.isRequired,
    planTypes:   React.PropTypes.array.isRequired,
    travelPlan:  React.PropTypes.object.isRequired,
  },


  getInitialState() {
    return {
      type: this.props.defaultType,
      flights: [{}],
    }
  },


  noOfFlights() {
    return this.state.flights.length;
  },


  addFlight() {
    var flights = this.state.flights;
    flights.push({})
    this.setState({flights: flights});
  },


  changeType(e) {
    this.setState({ type: e.target.value });
  },


  removeFlight(e) {
    var flights = this.state.flights;
    // remove this flight from the array:
    flights.splice(e.target.dataset.flightIndex, 1)
    this.setState({ flights: flights });
  },


  render() {
    var that = this;

    var flights = [];
    for (var i = 0; i < this.noOfFlights(); i++) {
      flights.push(
        <FlightFields
          key={i}
          index={i}
          showRemoveBtn={this.state.type === "multi" && this.noOfFlights() > 1}
          onRemoveBtnClick={this.removeFlight}
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

        {flights}

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
            <AddFlightBtn
              hidden={this.state.type !== "multi"}
              onClick={this.addFlight}
            />
          </div>
        </div>
      </div>
    )
  }
});
