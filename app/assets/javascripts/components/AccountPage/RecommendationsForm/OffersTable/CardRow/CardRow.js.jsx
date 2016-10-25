import React from "react";

const CardRow = React.createClass({
  propTypes: {
    card: React.PropTypes.object.isRequired,
  },
  render() {
    const card = this.props.card;

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
  },
});

export default CardRow;
