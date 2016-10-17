import React from "react";

import Row from "../../core/Row";
import TravelPlansListItem from "./TravelPlanListItem";

const TravelPlansList = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <Row>
      <div className="col-xs-12">
        <Row>
          <div className="col-xs-12">
            <p className="section-title">Travel Plans</p>
          </div>
        </Row>
      </div>

      <div className="col-xs-12">
        { props.travelPlans.map(travelPlan => (
          <TravelPlansListItem
            key={travelPlan.id}
            travelPlan={travelPlan}
          />
        ))}
      </div>
    </Row>
  );
};

TravelPlansList.propTypes = Object.assign(
  {
    travelPlans: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  }
);

export default TravelPlansList;
