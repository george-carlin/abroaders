import React from "react";
import _     from "underscore";
import $     from "jquery";

import EstimateItem from "./EstimateItem";

const PointsEstimateList = React.createClass({
  propTypes: {
    travelPlan: React.PropTypes.object.isRequired,
  },

  getInitialState() {
    return { data: {} };
  },

  componentDidMount() {
    const travelPlan     = this.props.travelPlan;
    const from           = travelPlan.flights[0].from;
    const to             = travelPlan.flights[0].to;
    const type           = travelPlan.type;
    const noOfPassengers = travelPlan.noOfPassengers;

    const url = `/estimates/${from.code}/${to.code}/${type}/${noOfPassengers}`;

    this.serverRequest = $.get(url, (result) => {
      this.setState({data: result});
    });
  },

  componentWillUnmount() {
    this.serverRequest.abort();
  },

  render() {
    if (_.isEmpty(this.state.data)) {
      return <noscript />;
    }

    const data = this.state.data;

    return (
        <div>
          <EstimateItem
            cosName="Economy"
            points={data.points.economy}
          />
          <EstimateItem
            cosName="Business"
            points={data.points.business_class}
          />
          <EstimateItem
            cosName="First"
            points={data.points.first_class}
          />
        </div>
    );
  },
});

export default PointsEstimateList;
