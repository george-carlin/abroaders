import React from "react";

const HomeAirportItem = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <li>{props.homeAirport.fullName}</li>
  );
};

HomeAirportItem.propTypes = Object.assign(
  {
    homeAirport: React.PropTypes.object.isRequired,
  }
);

export default HomeAirportItem;
