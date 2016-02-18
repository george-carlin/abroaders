var SubmitTag = React.createClass({
  getDefaultProps: function() {
    return {
      disabled: false,
      value:    "Save changes",
    };
  },


  propTypes: {
    disabled: React.PropTypes.bool,
    value:    React.PropTypes.string,
  },


  render() {
    return (
      <input
        type="submit"
        defaultValue={this.props.value}
        className="SubmitTag btn btn-primary"
        disabled={this.props.disabled}
      />
    );
  },

});
