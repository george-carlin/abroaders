var UsersTableHeader = React.createClass({
  propTypes: {
    sortFunction: React.PropTypes.func.isRequired
  },

  render() {
    var nameColStatus, emailColStatus, createdAtColStatus;

    switch (this.props.sortKey) {
      case "name":
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
          <th className="sortable-column-header" data-col-name="fullName"
                    onClick={this.props.sortFunction}>
            Name
          </th>
          <th className="sortable-column-header" data-col-name="email"
                    onClick={this.props.sortFunction}>
            Email
          </th>
          <th className="sortable-column-header" data-col-name="createdAt"
                    onClick={this.props.sortFunction}>
            Signed up
          </th>
          <th colSpan="3"></th>
        </tr>
      </thead>
    );
  }
});
