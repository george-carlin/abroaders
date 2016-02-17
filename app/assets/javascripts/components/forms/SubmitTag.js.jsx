var SubmitTag = React.createClass({
  getDefaultProps: function() {
    return {
      value: "Save changes",
    };
  },


  propTypes: {
    value: React.PropTypes.string
  },


  render() {
    return (
      <input
        type="submit"
        defaultValue={this.props.value}
        className="SubmitTag btn btn-primary"
      />
    );
  },

});
