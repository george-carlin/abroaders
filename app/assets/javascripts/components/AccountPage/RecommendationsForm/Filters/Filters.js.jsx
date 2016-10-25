import React from "react";

import Row from "../../../core/Row";

import PersonalBusinessFilter from "./PersonalBusinessFilter";
import BankCurrencyFilter     from "./BankCurrencyFilter";

const Filters = (_props) => {
  const props = Object.assign({}, _props);

  return (
    <Row className="filters-area">
      <div className="col-xs-12">
        <PersonalBusinessFilter
          onChangeOne={props.onChangeOne}
          bpChecked={props.bpChecked}
        />
      </div>

      <div className="col-xs-12">
        <BankCurrencyFilter
          alliances={props.alliances}
          banks={props.banks}
          independentCurrencies={props.independentCurrencies}
          onChangeOne={props.onChangeOne}
          onChangeAll={props.onChangeAll}
          banksChecked={props.banksChecked}
          currenciesChecked={props.currenciesChecked}
          filterAllChecked={props.filterAllChecked}
        />
      </div>
    </Row>
  );
};

Filters.propTypes = Object.assign(
  {
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    onChangeOne: React.PropTypes.func.isRequired,
    onChangeAll: React.PropTypes.func.isRequired,
    bpChecked: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
    banksChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
    currenciesChecked: React.PropTypes.arrayOf(React.PropTypes.number).isRequired,
    filterAllChecked: React.PropTypes.arrayOf(React.PropTypes.string).isRequired,
  }
);

export default Filters;
