import React from "react";

const OfferRow = (_props) => {
  const props = Object.assign({}, _props);
  const offer = props.offer;

  return (
    <tr>
      <td>{offer.identifier}</td>
      <td>Points: {offer.pointsAwarded}</td>
      <td>Spend: {offer.spend}</td>
      <td>Cost: {offer.cost}</td>
      <td>Days: {offer.days}</td>
      <td className="link-td">
        <a href={offer.link} rel="nofollow" target="_blank">Link</a>
      </td>
      <td></td>
    </tr>
  );
};

OfferRow.propTypes = Object.assign(
  {
    offer: React.PropTypes.object.isRequired,
  }
);

export default OfferRow;
