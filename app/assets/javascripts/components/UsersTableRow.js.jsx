var UsersTableRow = React.createClass({
  propTypes: {
    user: React.PropTypes.object.isRequired,
  },

  render() {
    return (
      <tr>
        <td>{this.props.user.attributes.fullName}</td>
        <td>{this.props.user.attributes.email}</td>
        <td>{this.props.user.attributes.prettyCreatedAt}</td>
        <td>{/*<Link to={`admin/users/${this.props.user.id}`}>Show</Link>*/}</td>
        <td>Edit</td>
        <td>Destroy</td>
      </tr>
    )
  }
});
