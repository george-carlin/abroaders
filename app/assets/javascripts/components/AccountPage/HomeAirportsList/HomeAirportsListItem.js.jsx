import React from "react";

const HomeAirportsListItem = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <li>{props.homeAirport.fullName}</li>
  );
};

HomeAirportsListItem.propTypes = Object.assign(
  {
    homeAirport: React.PropTypes.object.isRequired,
  }
);

export default HomeAirportsListItem;
