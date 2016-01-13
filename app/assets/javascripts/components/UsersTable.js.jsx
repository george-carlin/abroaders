var UsersTable = React.createClass({

  propTypes: {
    users: React.PropTypes.object.isRequired
  },


  getInitialState() {
    return {
      filterText: "",
      sortKey:    "email",
      sortOrder:  "asc"
    }
  },

  _filterUsers(e) {
    this.setState({ filterText: e.target.value });
  },


  _sort(e) {
    var newOrder;

    if (this.state.sortKey != newOrder.dataset.colName || this.state.sortOrder == "desc") {
      newOrder = "asc";
    } else {
      newOrder = "desc";
    }

    this.setState({sortKey: key, sortOrder: newOrder});
  },


  render() {
    var users = humps.camelizeKeys(this.props.users.data).map(function (user) {
      // Convert date strings to Date objects so we can sort by them
      user.createdAt = new Date(user.createdAt);
      return user;
    }).sort(function (user0, user1) {
      var name0 = user0.attributes[this.state.sortKey].toLowerCase();
      var name1 = user1.attributes[this.state.sortKey].toLowerCase();

      var result = name0 > name1 ? 1 : name0 < name1 ? -1 : 0;

      if (this.state.sortOrder !== "asc") {
        result = result * -1;
      }
      return result;
    }.bind(this))

    var filterText = this.state.filterText.toLowerCase().trim();
    if (filterText) {
      users = users.filter(function (user) {
        return user.attributes.fullName.toLowerCase().includes(filterText) ||
                user.attributes.email.toLowerCase().includes(filterText);
      });
    }

    return(
      <div>
        <UsersTableFilterInput
          filterText={this.state.filterText}
          onChangeHandler={this._filterUsers} />
        <table id="admin_users_table" className="users table table-striped">
          <UsersTableHeader
            sortKey={true/*this.state.sortKey*/}
            sortOrder={true/*this.state.sortOrder*/}
            onSortIconClick={true/*this.handleSortIconClick*/}
            sortFunction={this._sort} />
          <tbody>
            {users.map(function (user) {
              return <UsersTableRow key={user.id} user={user}/>
            })}
          </tbody>
        </table>
      </div>
    )
  }
});
