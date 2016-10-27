import React from "react";

const RegionsOfInterestListItem = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <li>{props.regionOfInterest.name}</li>
  );
};

RegionsOfInterestListItem.propTypes = Object.assign(
  {
    regionOfInterest: React.PropTypes.object.isRequired,
  }
);

export default RegionsOfInterestListItem;
