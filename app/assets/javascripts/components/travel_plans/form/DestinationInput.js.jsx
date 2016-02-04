var DestinationInput = React.createClass({

  propTypes: {
    dest:     React.PropTypes.oneOf(["from", "to"]),
    legIndex: React.PropTypes.number.isRequired,
  },

  render() {
    var dest     = this.props.dest,
        legIndex = this.props.legIndex,
        formGroupClasses = "col-xs-12 col-sm-5 form-group " +
                           "travel-plan-destination-form-group";

    var key = `travel_plan_legs_attributes_${legIndex}`;

    return (
      <div className={formGroupClasses}>
        <label htmlFor={`${key}_${dest}`}>{dest.capitalize()}</label>
        <input
          id={`${key}_${dest}`}
          type="text"
          className="destination-typeahead form-control"
          name={`travel_plan[legs_attributes][${legIndex}][${dest}]`}
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
          name={`travel_plan[legs_attributes][${legIndex}][${dest}_id]`}
        />
      </div>
    )
  }

});
