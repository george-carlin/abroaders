import React from "react";

import Row         from "../../../core/Row";
import FilterPanel from "./FilterPanel";

const BankCurrencyFilter = (_props) => {
  const props  = Object.assign({}, _props);

  return (
    <Row>
      <FilterPanel
        title="Banks"
        items={props.banks}
        target="bank"
        onChangeOne={props.onChangeOne}
        onChangeAll={props.onChangeAll}
        banksChecked={props.banksChecked}
        idsChecked={props.banksChecked}
        filterAllChecked={props.filterAllChecked.indexOf("banks") > -1}
      />

      { props.alliances.map(alliance => (
        <FilterPanel
          key={alliance.id}
          title={alliance.name}
          items={alliance.currencies}
          target="currency"
          onChangeOne={props.onChangeOne}
          onChangeAll={props.onChangeAll}
          idsChecked={props.currenciesChecked}
          filterAllChecked={props.filterAllChecked.indexOf(alliance.name.toLowerCase()) > -1}
        />
      ))}

      <FilterPanel
        title="Indy"
        items={props.independentCurrencies}
        target="currency"
        onChangeOne={props.onChangeOne}
        onChangeAll={props.onChangeAll}
        idsChecked={props.currenciesChecked}
        filterAllChecked={props.filterAllChecked.indexOf("indy") > -1}
      />
    </Row>
  );
};

BankCurrencyFilter.propTypes = Object.assign(
  {
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    onChangeOne: React.PropTypes.func.isRequired,
    onChangeAll: React.PropTypes.func.isRequired,
    banksChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
    currenciesChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
    filterAllChecked: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
  }
);

export default BankCurrencyFilter;
