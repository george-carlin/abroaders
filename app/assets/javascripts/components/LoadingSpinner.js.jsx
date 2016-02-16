var LoadingSpinner = React.createClass({

  getDefaultProps() {
    return { hidden: false };
  },


  propTypes: {
    hidden: React.PropTypes.bool,
    id:     React.PropTypes.string,
  },


  render() {
    var style;

    if (this.props.hidden) {
      style = { display: "none" };
    } else {
      style = {};
    }

    return (
      <div
        className="LoadingSpinner"
        style={style}
      >
        Loading...
      </div>
    );
  },

});
