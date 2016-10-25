import React from "react";

import OfferRow from "./OfferRow";
import CardRow  from "./CardRow";

const OffersTable = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    offers: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  groupBy(array, f) {
    const groups = {};
    array.forEach((o) => {
      const group = JSON.stringify(f(o));
      groups[group] = groups[group] || [];
      groups[group].push(o);
    });
    return Object.keys(groups).map((group) => {
      return groups[group];
    });
  },

  render() {
    const offers = this.groupBy(this.props.offers, (item) => {
      return [item.card.id];
    });

    return (
      <div className="col-xs-12 col-md-6">
        <p>Available Offers</p>

        <div className="table-wrapper">
          <table className="table table-striped offers-table">
            <thead>
            <tr>
              <th>ID</th>
              <th>Bank</th>
              <th>Name</th>
              <th>B/P</th>
              <th>Currency</th>
              <th></th>
              <th></th>
            </tr>
            </thead>
            <tbody>
              { offers.map(offersGroupedByCard => (
                [<CardRow
                  card={offersGroupedByCard[0].card}
                />,
                offersGroupedByCard.map(offer => (
                  <OfferRow
                    offer={offer}
                  />
                ))]
              ))}
            </tbody>
          </table>
        </div>
      </div>
    );
  },
});

export default OffersTable;
