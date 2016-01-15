var UsersTableHeader = React.createClass({
  propTypes: {
    sortFunction: React.PropTypes.func.isRequired,
    sortKey:      React.PropTypes.string.isRequired,
    sortOrder:    React.PropTypes.string.isRequired
  },

  render() {
    var nameColStatus, emailColStatus, createdAtColStatus;

    switch (this.props.sortKey) {
      case "fullName":
        nameColStatus  = this.props.sortOrder;
        emailColStatus = createdAtColStatus = "hidden";
        break;
      case "email":
        emailColStatus = this.props.sortOrder;
        nameColStatus  = createdAtColStatus = "hidden";
        break;
      case "createdAt":
        createdAtColStatus = this.props.sortOrder;
        nameColStatus = emailColStatus = "hidden";
        break;
    }

    return (
      <thead>
        <tr>
          <th className="sortable-column-header"
                    onClick={this.props.sortFunction.bind(null, "fullName")}>
            Name
            &nbsp;
            <SortIcon column="fullName" status={nameColStatus} />
          </th>
          <th className="sortable-column-header"
                    onClick={this.props.sortFunction.bind(null, "email")}>
            Email
            &nbsp;
            <SortIcon column="email" status={emailColStatus} />
          </th>
          <th className="sortable-column-header"
                    onClick={this.props.sortFunction.bind(null, "createdAt")}>
            Signed up
            &nbsp;
            <SortIcon column="createdAt" status={createdAtColStatus} />
          </th>
          <th colSpan="3"></th>
        </tr>
      </thead>
    );
  }
});
