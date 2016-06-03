// Including the react-rails gem alongside browserify-rails created
// all kinds of headaches, and is discouraged in browserify-rails's own
// README. So we're including React in the 'normal' NPM way (i.e. 
// via package.json) - but react-rails's UJS helpers are too good to
// give up on completely. This JS file provides an approximation
// of what we had before with react-rails.
//
// When that gem was included, we could write:
//
//   <%=
//     react_component(
//       "TravelPlanForm",
//       defaultType: TravelPlan::DEFAULT_TYPE,
//       maxFlights:  TravelPlan::MAX_FLIGHTS,
//       planTypes:   TravelPlan::TYPES,
//       travelPlan:  @travel_plan.attributes,
//       url:         travel_plans_path
//     )
//   %>
//
// Instead, we now write:
//
//   <div
//     data-react-component="TravelPlanForm"
//     data-default-type="<%=TravelPlan::DEFAULT_TYPE %>"
//     data-max-flights="<%= TravelPlan::MAX_FLIGHTS %>"
//     data-plan-types="<%=  TravelPlan::TYPES.to_json %>"
//     data-travel-plan="<%= @travel_plan.attributes.to_json %>"
//     data-url="<%= travel_plans_path %>"
//   ></div>
//
// (Any data attribute that's not called 'component' is assumed to be a prop of
// the react component)

const $     = require("jquery");
const _     = require("underscore");
const humps = require("humps");

$(document).ready(function () {
  $("[data-react-component]").each(function (i, el) {
    const $el  = $(el);
    const data = $el.data();

    // Use jQuery.prototype.data rather than el.dataSet so that any props whose
    // values are a JSON string will get automatically parsed and converted to
    // a JS object (rather than left as a string).

    const componentName = data.reactComponent;
    const component = window[componentName];
    if (typeof component === "undefined") {
      throw "Unable to find React component called " + componentName;
    }

    delete data.reactComponent;
    const props = {};
    _.each($el.data(), function(value, propName) {
      if (typeof value === "object") {
        value = humps.camelizeKeys(value);
      }
      props[propName] = value;
    });

    ReactDOM.render(
      React.createElement(component, props),
      el
    );
  });
});