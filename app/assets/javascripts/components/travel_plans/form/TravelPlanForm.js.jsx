var TravelPlanForm = React.createClass({
  propTypes: {
    defaultType: React.PropTypes.string.isRequired,
    maxFlights:  React.PropTypes.number.isRequired,
    planTypes:   React.PropTypes.array.isRequired,
    travelPlan:  React.PropTypes.object.isRequired,
    url:         React.PropTypes.string.isRequired,
  },

  getInitialState() {
    return {
      csrfToken:        "",
    }
  },


  getInitialState() {
    return {
      type: this.props.defaultType,
      flights: [{}],
    }
  },


  // TODO this is an exact dupe of code in CardDeclineForm. How to DRY this?
  componentDidMount() {
    // Hack to get the csrf-token into the form. `csrf_meta_tags` doesn't
    // output anything in test mode, so only add this hack if the querySelector
    // returns anything:
    var csrfMetaTag = document.querySelector('meta[name="csrf-token"]')
    if (csrfMetaTag) {
      this.setState({
        csrfToken: csrfMetaTag.content
      });
    }
  },


  noOfFlights() {
    return this.state.flights.length;
  },


  addFlight(e) {
    e.preventDefault();
    var flights = this.state.flights;
    flights.push({})
    this.setState({flights: flights});
  },


  changeType(e) {
    var flights,
    type = e.target.value;
    this.setState({ type: type });
    if (type === "single" || type === "return") {
      flights = this.state.flights;
      flights.splice(1); // Remove all flights except the first one
      this.setState({ flights: flights });
    }
  },


  removeFlight(e) {
    e.preventDefault();
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
      <form action={this.props.url} method="post">
        <AuthTokenField value={this.state.csrfToken} />

        <Row>
          <div className="col-xs-12">
            <TravelPlanTypeRadios
              types={this.props.planTypes}
              currentType={this.state.type}
              onChange={this.changeType}
            />
          </div>
        </Row>

        {flights}

        <Row>
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
        </Row>

        <Row>
          <div className="col-xs-12">
            <SubmitTag value="Save" />
          </div>
        </Row>
      </form>
    )
  }
});
