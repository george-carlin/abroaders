var UsersTableFilterInput = React.createClass({
  render() {
    return (
      <input
        type="text"
        className="form-control"
        placeholder="Filter"
        onChange={this.props.onChangeHandler} />
    )
  }
});
