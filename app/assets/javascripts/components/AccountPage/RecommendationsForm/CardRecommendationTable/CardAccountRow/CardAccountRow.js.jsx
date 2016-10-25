import React from "react";

const CardAccountRow = (_props) => {
  const props = Object.assign({}, _props);
  const cardAccount = props.cardAccount;

  return (
    <tr>
      <td>{cardAccount.card.identifier}</td>
      <td>{cardAccount.card.bank.name}</td>
      <td>{cardAccount.card.name}</td>
      <td>{cardAccount.status}</td>
      <td className="cardAccount_applied_at" data-text="cardAccount.applied_at_value ">
        {cardAccount.appliedAt}
      </td>
      <td className="cardAccount_opened_at" data-text="cardAccount.opened_at_value ">
        {cardAccount.openedAt}
      </td>
      <td className="cardAccount_closed_at" data-text="cardAccount.closed_at_value ">
        {cardAccount.closedAt}
      </td>
    </tr>
  );
};

CardAccountRow.propTypes = Object.assign(
  {
    cardAccount: React.PropTypes.object.isRequired,
  }
);

export default CardAccountRow;
