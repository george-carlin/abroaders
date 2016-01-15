var UsersTableFilterInput = React.createClass({

  propTypes: {
    onChangeHandler: React.PropTypes.func.isRequired
  },

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
