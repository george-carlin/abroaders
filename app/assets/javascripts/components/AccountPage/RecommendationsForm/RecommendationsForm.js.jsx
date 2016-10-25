import React from "react";

import Row                     from "../../core/Row";
import Filters                 from "./Filters";
import CardRecommendationTable from "./CardRecommendationTable";
import OffersTable             from "./OffersTable";

const RecommendationsForm = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    alliances: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    banks: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    independentCurrencies: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
    offers: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  getInitialState() {
    return {
      filterBP: [],
      filterCurrency: [],
      filterBank: [],
      filterAll: [],
    };
  },

  onChangeOne(checkbox, panel) {
    const props   = checkbox.props;
    const state   = this.state;
    const checked = props.checked;
    let value     = parseInt(props.value, 10);
    let newFilter;

    if (props.target === "currency") {
      newFilter = this.getNewFilter(state.filterCurrency, checked, value);
      this.setState({filterCurrency: newFilter});
      this.updateFilterAll(panel);
    } else if (props.target === "bank") {
      newFilter = this.getNewFilter(state.filterBank, checked, value);
      this.setState({filterBank: newFilter});
      this.updateFilterAll(panel);
    } else {
      value = props.value;
      newFilter = this.getNewFilter(state.filterBP, checked, value);
      this.setState({filterBP: newFilter});
    }
  },

  onChangeAll(checkbox) {
    const props   = checkbox.props;
    const state   = this.state;
    const checked = props.filterAllChecked;
    let newFilter = [];

    if (props.target === "currency") {
      newFilter = this.getNewFilterForAll(state.filterCurrency, props);
      this.setState({filterCurrency: newFilter});
    } else if (props.target === "bank") {
      newFilter = this.getNewFilterForAll(state.filterBank, props);
      this.setState({filterBank: newFilter});
    }

    const newFilterAll = this.getNewFilter(state.filterAll, checked, props.title.toLowerCase());
    this.setState({filterAll: newFilterAll});
  },

  getNewFilter(array, checked, value) {
    if (checked) {
      const index = array.indexOf(value);
      if (index > -1) {
        array.splice(index, 1);
      }
    } else {
      array.push(value);
    }

    return array;
  },

  getNewFilterForAll(array, props) {
    if (props.filterAllChecked) {
      props.items.forEach((item) => {
        const index = array.indexOf(item.id);
        if (index > -1) {
          array.splice(index, 1);
        }
      });
    } else {
      props.items.forEach((item) => {
        if (array.indexOf(item.id) === -1) {
          array.push(item.id);
        }
      });
    }

    return array;
  },

  updateFilterAll(panel) {
    const panelProps = panel.props;
    const checkedPanelItems = [];
    const title = panelProps.title.toLowerCase();

    panelProps.items.forEach((item) => {
      if (panelProps.idsChecked.indexOf(item.id) > -1) {
        checkedPanelItems.push(item.id);
      }
    });

    const allChecked = checkedPanelItems.length === panelProps.items.length;
    const newFilterAll = this.getNewFilter(this.state.filterAll, !allChecked, title);
    this.setState({filterAll: newFilterAll});
  },

  filterByCard(objects) {
    const filterBP       = this.state.filterBP;
    const filterBank     = this.state.filterBank;
    const filterCurrency = this.state.filterCurrency;

    return objects.filter((object) => {
      const card = object.card;
      return (
        (filterBP.length === 0 || filterBP.indexOf(card.bp) > -1) &&
        (filterCurrency.length === 0 || filterCurrency.indexOf(card.currency.id) > -1) &&
        (filterBank.length === 0 || filterBank.indexOf(card.bank.id) > -1)
      );
    });
  },

  render() {
    const person       = this.props.person;
    const cardAccounts = this.filterByCard(person.cardAccounts);
    const offers       = this.filterByCard(this.props.offers);

    return (
      <div>
        <Filters
          alliances={this.props.alliances}
          banks={this.props.banks}
          independentCurrencies={this.props.independentCurrencies}
          onChangeOne={this.onChangeOne}
          onChangeAll={this.onChangeAll}
          bpChecked={this.state.filterBP}
          currenciesChecked={this.state.filterCurrency}
          banksChecked={this.state.filterBank}
          filterAllChecked={this.state.filterAll}
        />

        <Row>
          <CardRecommendationTable
            person={person}
            cardAccounts={cardAccounts}
          />

          <OffersTable
            person={person}
            offers={offers}
          />
        </Row>
      </div>
    );
  },
});

export default RecommendationsForm;
