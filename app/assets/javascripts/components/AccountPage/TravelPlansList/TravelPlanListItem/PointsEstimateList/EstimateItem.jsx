import React  from "react";
import numbro from "numbro";

const EstimateItem = ({cosName, points}) => {
  return (
    <p>
      {cosName} {numbro(points.low).format("0,0")}
      {(() => {
        if (points.low !== points.high) {
          return (
            <span>
              &nbsp;-&nbsp;
              {numbro(points.high).format("0,0")}
            </span>
          );
        }
      })()}
    </p>
  );
};

export default EstimateItem;
