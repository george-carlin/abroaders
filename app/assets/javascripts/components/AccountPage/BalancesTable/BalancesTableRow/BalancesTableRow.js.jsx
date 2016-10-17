import React from "react";

import Row from "../../../core/Row";
import CurrencyRow from "./CurrencyRow";

const BalancesTableRow = (_props) => {
  const props      = Object.assign({}, _props);
  const currencies = props.currencies;
  const className  = currencies.length === 0 ? "hidden" : "alliance-row";

  return (
    <Row className={className}>
      <div className="col-xs-2 title">{props.title}</div>
      <div className="col-xs-10">
        {currencies.map(currency => (
          <CurrencyRow
            key={currency.id}
            currency={currency}
            account={props.account}
          />
        ))}
      </div>
    </Row>
  );
};

BalancesTableRow.propTypes = Object.assign(
  {
    title: React.PropTypes.string.isRequired,
    currencies: React.PropTypes.array.isRequired,
    account: React.PropTypes.object.isRequired,
  }
);

export default BalancesTableRow;
