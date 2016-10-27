import React from "react";

const CardRow = (_props) => {
  const props = Object.assign({}, _props);
  const card = props.card;

  return (
    <tr className="admin-recommend-card">
      <td>{card.identifier}</td>
      <td>{card.name}</td>
      <td>{card.bank.name}</td>
      <td className="text-capitalize">{card.bp}</td>
      <td>{card.currency.fullName}</td>
      <td></td>
      <td></td>
    </tr>
  );
};

CardRow.propTypes = Object.assign(
  {
    card: React.PropTypes.object.isRequired,
  }
);

export default CardRow;
