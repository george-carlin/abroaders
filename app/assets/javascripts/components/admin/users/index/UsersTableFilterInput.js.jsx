var UsersTableFilterInput = React.createClass({

  propTypes: {
    onChangeHandler: React.PropTypes.func.isRequired
  },

  render() {
    return (
      <input
        id="admin_users_table_filter"
        type="text"
        className="form-control"
        placeholder="Filter"
        onChange={this.props.onChangeHandler} />
    )
  }
});
