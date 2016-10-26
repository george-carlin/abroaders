import React from "react";

import Row                from "../../../core/Row";
import Flight             from "./Flight";
import PointsEstimateList from "./PointsEstimateList";

const TravelPlanListItem = (_props) => {
  const props      = Object.assign({}, _props);
  const travelPlan = props.travelPlan;

  return (
    <Row>
      <div className="col-xs-12 travel-plan-info well">
        <Row>
          <div className="col-xs-12 col-md-6">
            <p>
              <span>
                <i className="fa fa-male"></i> x {travelPlan.noOfPassengers}
              </span>
              <span className="font-bold type"> {travelPlan.type}</span> {travelPlan.departOn}

              {(() => {
                if (travelPlan.returnOn) {
                  return (
                    " - " + travelPlan.returnOn
                  );
                }
              })()}
            </p>

            { travelPlan.flights.map(flight => (
              <Flight
                key={flight.id}
                flight={flight}
              />
            ))}

            <p>
              Classes: <span className="font-bold">{travelPlan.acceptableClasses}</span>
            </p>

            {(() => {
              if (travelPlan.furtherInformation) {
                return (
                  <p>Notes: {travelPlan.furtherInformation}</p>
                );
              }
            })()}
          </div>

          <div className="col-xs-12 col-md-6">
            <PointsEstimateList
              travelPlan={travelPlan}
            />
          </div>
        </Row>
      </div>
    </Row>
  );
};

TravelPlanListItem.propTypes = Object.assign(
  {
    travelPlan: React.PropTypes.object.isRequired,
  }
);

export default TravelPlanListItem;
