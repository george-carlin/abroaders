var DestinationInput = React.createClass({

  propTypes: {
    dest:     React.PropTypes.oneOf(["from", "to"]),
    flightIndex: React.PropTypes.number.isRequired,
  },

  render() {
    var dest             = this.props.dest,
        flightIndex      = this.props.flightIndex,
        formGroupClasses = "col-xs-12 col-sm-5 form-group " +
                           "travel-plan-destination-form-group";

    var key = `travel_plan_flights_attributes_${flightIndex}`;

    return (
      <div className={formGroupClasses}>
        <label htmlFor={`${key}_${dest}`}>{dest.capitalize()}</label>
        <input
          id={`${key}_${dest}`}
          type="text"
          className="destination-typeahead form-control"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}]`}
        />
        <div
          id={`${dest}-loading-spinner`}
          className="loading-spinner"
        >
          Loading...
        </div>
        <input
          id={`${key}_${dest}_id`}
          type="hidden"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}_id]`}
        />
      </div>
    )
  }

});
