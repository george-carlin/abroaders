var DestinationInput = React.createClass({

  propTypes: {
    dest: React.PropTypes.oneOf(["from", "to"]).isRequired,
    destinationId: React.PropTypes.number,
    flightIndex:   React.PropTypes.number.isRequired,
    onSelect:      React.PropTypes.func.isRequired,
  },


  getInitialState() {
    return {
      isLoading: false,
    }
  },


  initializeTypeahead(constructor) {
    var that = this,
    $element = $(constructor),
    $input   = $element.find("input[type=text]");

    $input.typeahead({
      afterSelect: function (item) {
        that.props.onSelect(that.props.flightIndex, that.props.dest, item.id);
      },

      displayText: function (destination, a, b) {
        var result = destination.name;

        if (destination.type !== "region") {
          result += " (" + destination.code + ")";
        }
        if (destination.type === "airport") {
          // The actual <i> tag needs to be added in the `highlighter` function
          // (so the HTML doesn't get escaped) - but that function has no way
          // of knowing whether or not the item in question is an airport.  So
          // add a property to the string. ... Except you can't add properties
          // to String literals, so we have to do it this hacky way. Ugh. TODO
          // test me in other browsers:
          result = new String(result);
          result.isAirport = true;
        }
        return result;
      },

      highlighter: function (item) {
        // Get the 'normal' result from the default highlighter function:
        var result = $.fn.typeahead.Constructor.prototype.highlighter.call(
          this, item
        );
        if (item.isAirport) {
          // Add the font-awesome icon:
          result = "<i class='fa fa-plane'> </i> " + result;
        };
        return result;
      },
      // User has to type at least 3 characters for loading to begin:
      minLength: 3,
      source: function (query, processSynchronously) {
        // This function is called whenever the user types something into
        // the input that requires a search to be made. So turn on the loading
        // spinner:
        that.setState({isLoading: true });

        var processAsynchronously = function (results) {
          // Bloodhound calls this once it's finished searching, which
          // means we can now hide the loading spinner:
          that.setState({isLoading: false });
          processSynchronously(results);
        };

        // bloodhound is initialized in
        // app/assets/javascripts/initialize-bloodhound.js

        // The 'processSynchronously' callback will be passed any results that
        // bloodhound pulls from the local cache. At the moment we're not
        // caching anything locally (which we should! TODO), so this callback
        // will always be passed an empty array. The 'processAsynchronously'
        // callback will be called with the results that bloodhound pulls from
        // the API.
        bloodhound.search(
          query, $.noop /*processSynchronously*/, processAsynchronously
        );


        // The actual results will be handled in the 'processSynchronously' and
        // 'processAsynchronously' callbacks that were passed to `bloodhound`
        // above. In the meantime just return an empty array (because we
        // haven't loaded any results at this point):
        return [];
      },
    });
  },


  render() {
    var dest             = this.props.dest,
        flightIndex      = this.props.flightIndex,
        formGroupClasses = "col-xs-12 col-sm-5 form-group " +
                           "DestinationInput";

    var key = `travel_plan_flights_attributes_${flightIndex}`;

    var spinnerStyle;

    return (
      <div
        className={formGroupClasses}
        ref={this.initializeTypeahead}
      >
        <label htmlFor={`${key}_${dest}`}>{dest.capitalize()}</label>
        <input
          autoComplete="off"
          id={`${key}_${dest}`}
          type="text"
          className="destination-typeahead form-control"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}]`}
        />
        <LoadingSpinner
          id={`${dest}-${flightIndex}-loading-spinner`}
          hidden={!this.state.isLoading}
        />
        <input
          id={`${key}_${dest}_id`}
          type="hidden"
          name={`travel_plan[flights_attributes][${flightIndex}][${dest}_id]`}
          value={this.props.destinationId}
        />
      </div>
    )
  }

});
