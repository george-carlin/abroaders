const React = require('react');
const _ = require("underscore");

const Row = require("../../Row");

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
      csrfToken: "",
    }
  },


  getInitialState() {
    return {
      type: this.props.defaultType,
      flights: [],
    }
  },


  componentWillMount() {
    this.addFlight();
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



  addFlight(e) {
    if (e) {
      e.preventDefault();
    }
    var flights = this.state.flights;
    flights.push({ fromId: null, toId: null })
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


  didSelectDestination(flightIndex, dest, id) {
    // dest = one of 'from' or 'to'
    var flights = this.state.flights,
    stateKey    = dest + "Id";
    flights[flightIndex][stateKey] = id;
    this.setState({flights: flights});
  },


  isFormEnabled() {
    return _.all(this.state.flights, function (flight) {
      return flight.fromId && flight.toId;
    });
  },


  getAddFlightBtnStatus() {
    if (this.state.type !== "multi") {
      return "hidden";
    } else if (this.state.flights.length >= this.props.maxFlights) {
      return "disabled";
    } else {
      return "active";
    }
  },


  render() {
    var that = this,
    addFlightBtnStatus = this.getAddFlightBtnStatus();

    return (
      <form action={this.props.url} method="post">
        <AuthTokenField value={this.state.csrfToken} />

        <Row>
          <div className="col-xs-8">
            <TravelPlanTypeRadios
              types={this.props.planTypes}
              currentType={this.state.type}
              onChange={this.changeType}
            />
          </div>

          <div className="col-xs-2">
            <AddFlightBtn
              onClick={this.addFlight}
              status={addFlightBtnStatus}
            />
          </div>
        </Row>

        {(function () {
          return _(that.state.flights.length).times(function (i) {
            return (
              <FlightFields
                key={i}
                index={i}
                showRemoveBtn={
                  that.state.type === "multi" && that.state.flights.length > 1
                }
                onRemoveBtnClick={that.removeFlight}
                onSelectDestination={that.didSelectDestination}
                fromId={that.state.flights[i].fromId}
                toId={that.state.flights[i].toId}
              />
            );
          });
        })()}

        <Row>
          <div className="col-xs-4">
            <label>No of passengers</label>
            <NumberFieldTag
              model="travel_plan"
              field="no_of_passengers"
              value={this.props.travelPlan.no_of_passengers}
            />
          </div>
        </Row>

        <Row>
          <div className="col-xs-12">
            <SubmitTag value="Save" disabled={!this.isFormEnabled()}/>
          </div>
        </Row>
      </form>
    )
  }
});

module.exports = TravelPlanForm;
