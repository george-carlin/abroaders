import React from "react";

import Row                       from "../../core/Row";
import RegionsOfInterestListItem from "./RegionsOfInterestListItem";

const RegionsOfInterestList = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <div className="col-xs-12 col-md-6">
      <p className="section-title">Regions of Interest</p>
      <ul>
        { props.regionsOfInterest.map(regionOfInterest => (
          <RegionsOfInterestListItem
            key={regionOfInterest.id}
            regionOfInterest={regionOfInterest}
          />
        ))}
      </ul>
    </div>
  );
};

RegionsOfInterestList.propTypes = Object.assign(
  {
    regionsOfInterest: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  }
);

export default RegionsOfInterestList;
