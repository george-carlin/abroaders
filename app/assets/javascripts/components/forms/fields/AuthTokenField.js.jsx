var AuthTokenField = React.createClass({
  propTypes: {
    value: React.PropTypes.string
  },

  render() {
    return (
      <input
        name="authenticity_token"
        type="hidden"
        value={this.props.value}
      />
    )
  },

});
