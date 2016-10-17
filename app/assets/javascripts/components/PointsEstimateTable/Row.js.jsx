import React  from "react";
import numbro from "numbro";

const Estimate = ({number, formatString}) => {
  return (
    <span className="Estimate">
      {numbro(number).format(formatString)}
    </span>
  );
};

const EstimateCell = ({data, formatString}) => {
  return (
    <td className="EstimateCell">
      <Estimate number={data.low} formatString={formatString} />
      {(() => {
        if (data.low !== data.high) {
          return (
            <span>
              &nbsp;-&nbsp;
              <Estimate number={data.high} formatString={formatString} />
            </span>
            );
        }
      })()}
    </td>
  );
};

const Row = ({cosName, points, fees}) => {
  return (
    <tr>
      <td className="ClassOfService">
        {cosName}
      </td>
      <EstimateCell data={points} formatString="0,0" />
      <EstimateCell data={fees} formatString="$0,0.00" />
    </tr>
  );
};

export default Row;
