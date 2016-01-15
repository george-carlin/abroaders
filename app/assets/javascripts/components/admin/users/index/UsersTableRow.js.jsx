var UsersTableRow = React.createClass({
  propTypes: {
    user: React.PropTypes.object.isRequired,
  },

  render() {
    var user     = this.props.user,
        showHref = `/admin/users/${user.id}`;
    return (
      <tr id={`user_${user.id}`}>
        <td>{user.attributes.fullName}</td>
        <td>{user.attributes.email}</td>
        <td>{user.attributes.prettyCreatedAt}</td>
        <td><a href={showHref}>Show</a></td>
        <td>Edit</td>
        <td>Destroy</td>
      </tr>
    )
  }
});
