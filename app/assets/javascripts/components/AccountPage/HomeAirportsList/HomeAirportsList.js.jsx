import React from "react";

import Row from "../../core/Row";
import HomeAirportItem from "./HomeAirportItem";

const HomeAirportsList = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <div className="col-xs-12 col-md-6">
      <p className="section-title">Home Airports</p>
      <ul>
        { props.homeAirports.map(airport => (
          <HomeAirportItem
            key={airport.id}
            homeAirport={airport}
          />
        ))}
      </ul>
    </div>
  );
};

HomeAirportsList.propTypes = Object.assign(
  {
    homeAirports: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  }
);

export default HomeAirportsList;
