var DestinationInput = React.createClass({

  propTypes: {
    dest:     React.PropTypes.oneOf(["from", "to"]),
    flightIndex: React.PropTypes.number.isRequired,
  },

  getInitialState() {
    return {
      selectedDestinationId: undefined,
      showSpinner: false,
    }
  },


  showSpinner() {
    this.setState({showSpinner: true})
  },



  displayDestination(searchResult) {
    return searchResult.name + " (" + searchResult.code + ")";
  },


  initializeTypeahead(constructor) {
    var that  = this,
    $element  = $(constructor),
    $input    = $element.find("input[type=text]");

    $input.typeahead({
      afterSelect: function (item) {
        that.setState({selectedDestinationId: item.id});
      },
      displayText: this.displayDestination,
      source: function (query, process) {
        // Hide the loading spinner when the search is complete.
        var wrapped = function (results) {
          that.setState({showSpinner: false });
          process(results);
        };
        // bloodhound is defined in app/assets/javascripts/bloodhound.js
        return bloodhound.search(query, process, wrapped);
      },
    });
  },


  render() {
    var dest             = this.props.dest,
        flightIndex      = this.props.flightIndex,
        formGroupClasses = "col-xs-12 col-sm-5 form-group " +
                           "travel-plan-destination-form-group";

    var key = `travel_plan_flights_attributes_${flightIndex}`;

    var spinnerStyle;
    if (this.state.showSpinner) {
      spinnerStyle = {};
    } else {
      spinnerStyle = { display: "none" };
    }

    return (
      <div
        className={formGroupClasses}
        ref={this.initializeTypeahead}
      >
        <label htmlFor={`${key}_${dest}`}>{dest.capitalize()}</label>
        <input
          id={`${key}_${dest}`}
          type="text"
          className="destination-typeahead form-control"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}]`}
          onChange={this.showSpinner}
        />
        <div
          id={`${dest}-${flightIndex}-loading-spinner`}
          className="loading-spinner"
          style={spinnerStyle}
        >
          Loading...
        </div>
        <input
          id={`${key}_${dest}_id`}
          type="hidden"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}_id]`}
          value={this.state.selectedDestinationId}
        />
      </div>
    )
  }

});
