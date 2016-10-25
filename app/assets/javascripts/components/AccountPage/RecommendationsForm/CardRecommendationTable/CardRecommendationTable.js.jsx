import React from "react";

import Reactable from "reactable";

const CardRecommendationTable = React.createClass({
  propTypes: {
    person: React.PropTypes.object.isRequired,
    cardAccounts: React.PropTypes.arrayOf(React.PropTypes.object).isRequired,
  },

  render() {
    let Table = Reactable.Table;
    let Thead = Reactable.Thead;
    let Th    = Reactable.Th;
    let Tr    = Reactable.Tr;
    let Td    = Reactable.Td;

    return (
      <div className="col-xs-12 col-md-6">
        <p>{this.props.person.firstName}'s Credit Cards</p>

        <div className="table-wrapper">
          <Table
            className="table table-striped card-accounts-table"
            noDataText="No matching records found"
            sortable={[
              {
                column: "applied",
                sortFunction: "Date",
              },
              {
                column: "opened",
                sortFunction: "Date",
              },
              {
                column: "closed",
                sortFunction: "Date",
              },
            ]}
            defaultSort={{column: "opened", direction: "desc"}}
            defaultSortDescending
          >
            <Thead>
              <Th column="id">ID</Th>
              <Th column="bank">Bank</Th>
              <Th column="name">Name</Th>
              <Th column="status">Status</Th>
              <Th column="applied">Applied</Th>
              <Th column="opened">Open</Th>
              <Th column="closed">Closed</Th>
            </Thead>

            { this.props.cardAccounts.map(cardAccount => (
              <Tr
                key={cardAccount.id}
              >
                <Td column="id">{cardAccount.card.identifier}</Td>
                <Td column="bank">{cardAccount.card.bank.name}</Td>
                <Td column="name">{cardAccount.card.name}</Td>
                <Td column="status" className="text-capitalize">{cardAccount.status}</Td>
                <Td column="applied">{cardAccount.appliedAt}</Td>
                <Td column="opened">{cardAccount.openedAt}</Td>
                <Td column="closed">{cardAccount.closedAt}</Td>
              </Tr>
            ))}
          </Table>
        </div>
      </div>
    );
  },
});

export default CardRecommendationTable;
