import React from "react";

import Row from "../../core/Row";

import PersonalBusinessFilter from "./PersonalBusinessFilter";
import RecommendationNotes    from "./RecommendationNotes";
import FilterPanel            from "./FilterPanel";

const Filters = (_props) => {
  const props   = Object.assign({}, _props);

  return (
    <Row className="filters-area">
      <div className="col-xs-12">
        <PersonalBusinessFilter
          onFilterPersonal={props.onFilterPersonal}
          onFilterBusiness={props.onFilterBusiness}
        />
      </div>

      <div className="col-xs-12">
        <Row>
          <FilterPanel
            title="Banks"
            items={props.banks}
            target="banks"
            onFilter={props.onFilterBank}
            onFilterAll={props.onFilterBanks}
          />

          { props.alliances.map(alliance => (
            <FilterPanel
              key={alliance.id}
              title={alliance.name}
              item={alliance}
              items={alliance.currencies}
              target="currency"
              onFilter={props.onFilterCurrency}
              onFilterAll={props.onFilterAlliance}
            />
          ))}

          <FilterPanel
            title="Indy"
            items={props.independentCurrencies}
            target="currency"
            onFilter={props.onFilterCurrency}
            onFilterAll={props.onFilterIndependent}
          />
        </Row>
      </div>
    </Row>
  );
};

Filters.propTypes = Object.assign(
  {
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    onFilterBank: React.PropTypes.func.isRequired,
    onFilterBanks: React.PropTypes.func.isRequired,
    onFilterCurrency: React.PropTypes.func.isRequired,
    onFilterAlliance: React.PropTypes.func.isRequired,
    onFilterIndependent: React.PropTypes.func.isRequired,
    onFilterPersonal: React.PropTypes.func.isRequired,
    onFilterBusiness: React.PropTypes.func.isRequired,
  }
);

export default Filters;
