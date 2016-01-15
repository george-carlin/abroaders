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


  _sortBy(columnName) {
    var newOrder;

    if (this.state.sortKey != columnName || this.state.sortOrder == "desc") {
      newOrder = "asc";
    } else {
      newOrder = "desc";
    }

    this.setState({sortKey: columnName, sortOrder: newOrder});
  },


  render() {
    var users = humps.camelizeKeys(this.props.users.data).map(function (user) {
      // Convert date strings to Date objects so we can sort by them
      user.attributes.createdAt = new Date(user.attributes.createdAt);
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
        const name  = user.attributes.fullName.toLowerCase()
        const email = user.attributes.email.toLowerCase()
        // String.prototype.includes would be better than indexOf but it's an
        // ES6 feature and doesn't work in PhantomJS (i.e. in the tests).  TODO
        // figure out how to make the transpiler work in test as well as dev
        // modes.
        return name.indexOf(filterText) > -1 || email.indexOf(filterText) > -1
      });
    }

    return(
      <div>
        <UsersTableFilterInput
          filterText={this.state.filterText}
          onChangeHandler={this._filterUsers} />
        <table id="admin_users_table" className="users table table-striped">
          <UsersTableHeader
            sortKey={this.state.sortKey}
            sortOrder={this.state.sortOrder}
            sortFunction={this._sortBy} />
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
